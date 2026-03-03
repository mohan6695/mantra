package com.mantra.mantra.audio

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * Audio engine for verse (long mantra) tracking mode.
 *
 * Instead of detecting mantra repetitions, this engine detects
 * individual word boundaries within a continuous chant, allowing
 * the Dart UI to follow along word-by-word through the verse text.
 *
 * Pipeline per frame:
 *   1. Read 512 samples (32ms) from mic
 *   2. Feed to WordBoundaryDetector state machine
 *   3. On word events → send to Flutter via EventSink
 *
 * The Dart side maintains a VerseTracker that maps word events
 * to positions in the predefined verse text.
 */
class VerseAudioEngine {

    companion object {
        private const val TAG = "VerseAudioEngine"
        private const val SAMPLE_RATE = 16000
        private const val FRAME_SIZE = 512
    }

    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var handlerThread: HandlerThread? = null
    private var handler: Handler? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private val detector = WordBoundaryDetector()

    /** Total number of words in the verse being tracked. */
    private var totalWords: Int = 0

    // EventSink for streaming word events to Dart
    var eventSink: EventChannel.EventSink? = null

    fun start(totalWords: Int, sensitivity: Double) {
        if (isRecording) return
        this.totalWords = totalWords

        // Configure detector based on sensitivity (0.5 = lenient, 1.0 = strict)
        detector.reset()
        detector.setFrameParams(SAMPLE_RATE, FRAME_SIZE)
        // Lower sensitivity = more lenient energy threshold
        detector.energyThreshold = 0.004 + (sensitivity * 0.008) // 0.004 - 0.012
        detector.minOnsetFrames = if (sensitivity > 0.7) 3 else 2
        detector.minPauseFrames = if (sensitivity > 0.7) 3 else 2
        detector.maxPauseMs = (400 + (1.0 - sensitivity) * 400).toLong() // 400-800ms
        detector.minWordDurationMs = 80

        // Wire word events to Flutter EventSink
        detector.onWordEvent = { event ->
            val map = when (event) {
                is WordEvent.WordStart -> mapOf<String, Any>(
                    "type" to "word_start",
                    "wordIndex" to event.wordIndex,
                    "timestamp" to event.timestampMs,
                    "energy" to event.energy
                )
                is WordEvent.WordAdvance -> mapOf<String, Any>(
                    "type" to "word_advance",
                    "wordIndex" to event.wordIndex,
                    "timestamp" to event.timestampMs,
                    "wordDuration" to event.prevWordDurationMs,
                    "pauseDuration" to event.pauseDurationMs
                )
                is WordEvent.LinePause -> mapOf<String, Any>(
                    "type" to "line_pause",
                    "wordIndex" to event.wordIndex,
                    "timestamp" to event.timestampMs,
                    "pauseDuration" to event.pauseDurationMs
                )
            }
            mainHandler.post {
                try {
                    eventSink?.success(map)
                } catch (e: Exception) {
                    Log.w(TAG, "Failed to send verse event: ${e.message}")
                }
            }
        }

        // Set up audio recording thread
        handlerThread = HandlerThread("VerseAudioThread").also { it.start() }
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
        Log.i(TAG, "Verse audio engine started (totalWords=$totalWords, sensitivity=$sensitivity)")
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
        detector.onWordEvent = null
        Log.i(TAG, "Verse audio engine stopped")
    }

    fun updateSensitivity(sensitivity: Double) {
        detector.energyThreshold = 0.004 + (sensitivity * 0.008)
        Log.i(TAG, "Sensitivity updated: energy=${detector.energyThreshold}")
    }

    private fun recordingLoop() {
        val buffer = ShortArray(FRAME_SIZE)
        var frameCount = 0

        while (isRecording) {
            val read = audioRecord?.read(buffer, 0, FRAME_SIZE) ?: 0
            if (read != FRAME_SIZE) continue

            frameCount++
            val now = System.currentTimeMillis()

            // Feed every frame to the word boundary detector
            detector.processFrame(buffer, now)

            // Debug log every 200 frames (~6.4 seconds)
            if (frameCount % 200 == 0) {
                val rms = sqrt(buffer.map { it.toDouble().pow(2) }.average()) / 32768.0
                Log.d(TAG, "Frame $frameCount: rms=${String.format("%.6f", rms)} wordsSoFar=${detector.run { 
                    // Access current word count via the next event index
                    frameCount // placeholder; actual count tracked in detector
                }}")
            }
        }
    }
}
