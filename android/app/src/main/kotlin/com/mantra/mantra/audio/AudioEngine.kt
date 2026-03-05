package com.mantra.mantra.audio

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel
import kotlin.math.*

/**
 * Native audio engine running on a dedicated thread.
 *
 * Pipeline:
 *   1. VAD gate (energy + ZCR) — skip silence
 *   2. Accumulate voiced frames into a segment
 *   3. When silence gap detected → emit segment with energy contour + duration
 *   4. Flutter/Dart ensemble detector handles scoring (or direct counting in simple mode)
 *
 * Sends segment maps compatible with Dart AudioSegment.fromNative():
 *   - durationMs, energyContour, voicedPattern, peakEnergy, timestamp
 *   - confidence (energy-based proxy for simple mode fallback)
 */
class AudioEngine {

    companion object {
        private const val TAG = "AudioEngine"
        private const val SAMPLE_RATE = 16000
        private const val FRAME_SIZE = 512          // ~32ms per frame
        private const val SILENCE_FRAMES = 10       // ~320ms silence = segment boundary
        private const val MIN_VOICED_FRAMES = 10    // ~320ms minimum segment (filters coughs/noise)
        private const val MAX_SEGMENT_FRAMES = 300  // ~9.6s max segment
        private const val MIN_SEGMENT_DURATION_MS = 500 // reject segments shorter than 500ms
        private const val ENERGY_CONTOUR_POINTS = 20 // downsample energy to 20 points
    }

    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var handlerThread: HandlerThread? = null
    private var handler: Handler? = null

    private var threshold: Float = 0.82f
    private var refractoryMs: Int = 800
    private var lastDetectionTime: Long = 0L
    private val mainHandler = Handler(Looper.getMainLooper())

    // EventSink for streaming detections to Dart
    var eventSink: EventChannel.EventSink? = null

    // Audio buffer manager for Sarvam ASR integration
    val bufferManager = AudioBufferManager()

    // Segment accumulator
    private val segmentEnergies = mutableListOf<Double>()
    private val segmentVoiced = mutableListOf<Boolean>()
    private var segmentStartTime: Long = 0L
    private var silenceCount = 0
    private var peakEnergy = 0.0

    fun start(mantras: List<Map<String, Any>>, threshold: Float) {
        if (isRecording) return
        this.threshold = threshold

        handlerThread = HandlerThread("AudioEngineThread").also { it.start() }
        handler = Handler(handlerThread!!.looper)

        val bufferSize = maxOf(
            AudioRecord.getMinBufferSize(
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            ) * 2,
            FRAME_SIZE * 2
        )

        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSize
            )
        } catch (e: SecurityException) {
            Log.e(TAG, "Mic permission not granted: ${e.message}")
            return
        }

        if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
            Log.e(TAG, "AudioRecord failed to initialize")
            audioRecord?.release()
            audioRecord = null
            return
        }

        isRecording = true
        resetSegment()
        audioRecord?.startRecording()
        handler?.post { recordingLoop() }
        Log.i(TAG, "Audio engine started with threshold=$threshold")
    }

    fun stop() {
        isRecording = false
        try {
            audioRecord?.stop()
            audioRecord?.release()
        } catch (e: Exception) {
            Log.w(TAG, "Error stopping AudioRecord: ${e.message}")
        }
        audioRecord = null
        handlerThread?.quitSafely()
        handlerThread = null
        handler = null
        Log.i(TAG, "Audio engine stopped")
    }

    fun updateCalibration(energyThreshold: Float, refractoryMs: Int) {
        VadGate.updateThresholds(energyThreshold.toDouble(), VadGate.zcrThreshold)
        this.refractoryMs = refractoryMs
        Log.i(TAG, "Calibration updated: energy=$energyThreshold, refractory=${refractoryMs}ms")
    }

    private fun resetSegment() {
        segmentEnergies.clear()
        segmentVoiced.clear()
        segmentStartTime = 0L
        silenceCount = 0
        peakEnergy = 0.0
    }

    private fun recordingLoop() {
        val buffer = ShortArray(FRAME_SIZE)
        var frameCount = 0

        while (isRecording) {
            val read = audioRecord?.read(buffer, 0, FRAME_SIZE) ?: 0
            if (read != FRAME_SIZE) continue

            frameCount++

            // Always buffer frames when buffering is active (for ASR)
            if (bufferManager.isActive()) {
                bufferManager.addFrame(buffer)
            }

            // Compute frame energy (normalized 0..1)
            val rms = sqrt(buffer.map { it.toDouble().pow(2) }.average()) / 32768.0
            val vadPassed = VadGate.isVoiceActive(buffer)

            // Debug: log every 100th frame
            if (frameCount % 100 == 0) {
                Log.d(TAG, "Frame $frameCount: rms=${String.format("%.6f", rms)} vad=$vadPassed seg=${segmentEnergies.size}")
            }

            if (vadPassed) {
                // Voice detected — accumulate into segment
                if (segmentEnergies.isEmpty()) {
                    segmentStartTime = System.currentTimeMillis()
                }
                segmentEnergies.add(rms)
                segmentVoiced.add(true)
                if (rms > peakEnergy) peakEnergy = rms
                silenceCount = 0

                // Safety: don't let segments grow forever
                if (segmentEnergies.size >= MAX_SEGMENT_FRAMES) {
                    emitSegment()
                    resetSegment()
                }
            } else {
                // Silence frame
                if (segmentEnergies.isNotEmpty()) {
                    segmentEnergies.add(rms)
                    segmentVoiced.add(false)
                    silenceCount++

                    // Enough silence = segment boundary
                    if (silenceCount >= SILENCE_FRAMES) {
                        if (segmentVoiced.count { it } >= MIN_VOICED_FRAMES) {
                            emitSegment()
                        }
                        resetSegment()
                    }
                }
            }
        }
    }

    private fun emitSegment() {
        val now = System.currentTimeMillis()

        // Refractory gate
        if (now - lastDetectionTime < refractoryMs) {
            Log.d(TAG, "Segment suppressed (refractory)")
            return
        }

        val voicedCount = segmentVoiced.count { it }
        val durationMs = (segmentEnergies.size * FRAME_SIZE * 1000L) / SAMPLE_RATE
        val confidence = (peakEnergy * 10.0).coerceIn(0.0, 1.0)

        // Duration check: reject segments too short to be a mantra chant
        if (durationMs < MIN_SEGMENT_DURATION_MS) {
            Log.d(TAG, "Segment too short: ${durationMs}ms < ${MIN_SEGMENT_DURATION_MS}ms")
            return
        }

        // Threshold check: peak energy must be meaningful
        if (confidence < threshold * 0.3) {
            Log.d(TAG, "Segment below threshold: confidence=$confidence")
            return
        }

        lastDetectionTime = now

        // Downsample energy contour to fixed-size array
        val contour = downsampleEnergy(segmentEnergies, ENERGY_CONTOUR_POINTS)

        Log.i(TAG, "Segment emitted: ${durationMs}ms, voiced=$voicedCount/${segmentEnergies.size}, peak=${String.format("%.4f", peakEnergy)}")

        // Build segment map compatible with Dart AudioSegment.fromNative()
        val event = hashMapOf<String, Any>(
            "durationMs" to durationMs.toInt(),
            "energyContour" to contour,
            "voicedPattern" to segmentVoiced.toList(),
            "peakEnergy" to peakEnergy,
            "timestamp" to now,
            "meanMfcc" to emptyList<Double>(),   // No MFCC on native side yet
            "mfcc" to emptyList<List<Double>>(),  // No MFCC on native side yet
            // Legacy fields for simple-mode fallback
            "confidence" to confidence,
            "index" to 0
        )

        mainHandler.post {
            try {
                eventSink?.success(event)
            } catch (e: Exception) {
                Log.w(TAG, "Failed to send segment event: ${e.message}")
            }
        }
    }

    private fun downsampleEnergy(energies: List<Double>, targetSize: Int): List<Double> {
        if (energies.size <= targetSize) {
            return energies.toList()
        }
        val result = mutableListOf<Double>()
        val step = energies.size.toDouble() / targetSize
        for (i in 0 until targetSize) {
            val start = (i * step).toInt()
            val end = ((i + 1) * step).toInt().coerceAtMost(energies.size)
            val avg = energies.subList(start, end).average()
            result.add(avg)
        }
        return result
    }
}
