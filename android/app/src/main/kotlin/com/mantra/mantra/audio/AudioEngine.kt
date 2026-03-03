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
 * Pipeline per frame (512 samples @ 16kHz = ~32ms):
 *   1. VAD gate (energy + ZCR) — skip if silence
 *   2. Compute RMS energy as a proxy confidence
 *   3. If energy-based detection passes threshold → send event to Flutter via EventSink
 *
 * TFLite inference can be plugged in later; for now amplitude-based detection
 * allows full end-to-end testing of the "Om Namah Shivaya" chanting session flow.
 */
class AudioEngine {

    companion object {
        private const val TAG = "AudioEngine"
        private const val SAMPLE_RATE = 16000
        private const val FRAME_SIZE = 512
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

    private fun recordingLoop() {
        val buffer = ShortArray(FRAME_SIZE)
        var frameCount = 0
        while (isRecording) {
            val read = audioRecord?.read(buffer, 0, FRAME_SIZE) ?: 0
            if (read != FRAME_SIZE) continue

            frameCount++
            // Step 1: VAD gate — skip silence
            val vadPassed = VadGate.isVoiceActive(buffer)

            // Debug: log every 100th frame regardless of VAD
            if (frameCount % 100 == 0) {
                val rmsDbg = sqrt(buffer.map { it.toDouble().pow(2) }.average()) / 32768.0
                Log.d(TAG, "Frame $frameCount: rms=${String.format("%.6f", rmsDbg)} vad=$vadPassed")
            }

            if (!vadPassed) continue

            // Step 2: Compute RMS energy as confidence proxy (0.0 - 1.0)
            val rms = sqrt(buffer.map { it.toDouble().pow(2) }.average()) / 32768.0
            val confidence = (rms * 10.0).coerceIn(0.0, 1.0) // scale up for usability

            // Step 3: Refractory gate — prevent double-counting
            val now = System.currentTimeMillis()
            if (now - lastDetectionTime < refractoryMs) continue

            // Step 4: Threshold check
            if (confidence < threshold * 0.5) continue // relaxed for amplitude mode

            lastDetectionTime = now
            Log.i(TAG, "Detection! confidence=$confidence, frame=$frameCount")

            // Step 5: Emit detection to Flutter via EventSink (must be on main thread)
            val event = mapOf<String, Any>(
                "index" to 0, // Om Namah Shivaya = index 0
                "confidence" to confidence,
                "timestamp" to now
            )
            mainHandler.post {
                try {
                    eventSink?.success(event)
                } catch (e: Exception) {
                    Log.w(TAG, "Failed to send detection event: ${e.message}")
                }
            }
        }
    }
}
