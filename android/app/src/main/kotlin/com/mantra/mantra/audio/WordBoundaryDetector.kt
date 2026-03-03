package com.mantra.mantra.audio

import android.util.Log
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * Detects word boundaries in a continuous audio stream.
 *
 * Algorithm overview:
 * ┌──────────┐  energy rises   ┌──────────┐  energy dips   ┌───────┐
 * │ SILENCE  │ ──────────────→ │ SPEECH   │ ──────────────→│ PAUSE │
 * └──────────┘                 └──────────┘                └───────┘
 *       ↑                           ↑                          │
 *       │  pause > maxPauseMs       │   energy rises           │
 *       └───────────────────────────┼──────────────────────────┘
 *                                   │  (word boundary emitted!)
 *
 * State transitions:
 * - SILENCE → SPEECH : Energy exceeds threshold for minOnsetFrames → [WORD_START event]
 * - SPEECH  → PAUSE  : Energy drops below threshold for minPauseFrames
 * - PAUSE   → SPEECH : Energy rises again within maxPauseMs → [WORD_ADVANCE event]
 * - PAUSE   → SILENCE: Pause exceeds maxPauseMs → [LINE_PAUSE event]
 *
 * This approach works because mantra/verse chanting has natural micro-pauses
 * between words (typically 100-300ms), even in flowing chant.
 */
class WordBoundaryDetector {

    companion object {
        private const val TAG = "WordBoundary"
    }

    enum class State { SILENCE, SPEECH, PAUSE }

    // ── Tunable parameters ──────────────────────────────────
    /** RMS energy threshold to classify frame as speech vs. silence. */
    var energyThreshold: Double = 0.008

    /** Minimum consecutive speech frames to confirm speech onset (prevents clicks). */
    var minOnsetFrames: Int = 3

    /** Minimum consecutive low-energy frames to consider a pause. */
    var minPauseFrames: Int = 2

    /** Maximum pause duration (ms) before classifying as line break / full silence.
     *  Within this window, a new speech onset = word boundary. */
    var maxPauseMs: Long = 600

    /** Minimum word duration (ms). Reject words shorter than this. */
    var minWordDurationMs: Long = 100

    // ── Internal state ──────────────────────────────────────
    private var state = State.SILENCE
    private var consecutiveSpeechFrames = 0
    private var consecutiveSilenceFrames = 0
    private var speechStartTime: Long = 0
    private var pauseStartTime: Long = 0
    private var wordCount = 0
    private var frameDurationMs: Double = 32.0 // 512 samples @ 16kHz

    // ── Adaptive noise floor ────────────────────────────────
    /** Exponential moving average of ambient noise energy. */
    private var noiseFloorEnergy: Double = 0.0
    private var noiseFloorInitialized = false
    private val noiseFloorAlpha = 0.02 // slow adaptation

    // ── Callback ────────────────────────────────────────────
    var onWordEvent: ((WordEvent) -> Unit)? = null

    fun reset() {
        state = State.SILENCE
        consecutiveSpeechFrames = 0
        consecutiveSilenceFrames = 0
        wordCount = 0
        noiseFloorInitialized = false
        noiseFloorEnergy = 0.0
    }

    fun setFrameParams(sampleRate: Int, frameSize: Int) {
        frameDurationMs = (frameSize.toDouble() / sampleRate) * 1000.0
    }

    /**
     * Process a single audio frame and emit word boundary events.
     *
     * @param frame PCM 16-bit samples for this frame.
     * @param timestampMs Current wall-clock time.
     */
    fun processFrame(frame: ShortArray, timestampMs: Long) {
        val rms = computeRMS(frame)

        // Adapt noise floor during silence
        if (state == State.SILENCE) {
            if (!noiseFloorInitialized) {
                noiseFloorEnergy = rms
                noiseFloorInitialized = true
            } else {
                noiseFloorEnergy = noiseFloorEnergy * (1 - noiseFloorAlpha) + rms * noiseFloorAlpha
            }
        }

        // Effective threshold: max of fixed threshold, or 3x the noise floor
        val effectiveThreshold = maxOf(energyThreshold, noiseFloorEnergy * 3.0)
        val isSpeech = rms > effectiveThreshold

        when (state) {
            State.SILENCE -> {
                if (isSpeech) {
                    consecutiveSpeechFrames++
                    if (consecutiveSpeechFrames >= minOnsetFrames) {
                        state = State.SPEECH
                        speechStartTime = timestampMs
                        consecutiveSilenceFrames = 0
                        onWordEvent?.invoke(WordEvent.WordStart(
                            wordIndex = wordCount,
                            timestampMs = timestampMs,
                            energy = rms
                        ))
                        Log.d(TAG, "SILENCE→SPEECH word=$wordCount rms=${String.format("%.5f", rms)}")
                    }
                } else {
                    consecutiveSpeechFrames = 0
                }
            }

            State.SPEECH -> {
                if (!isSpeech) {
                    consecutiveSilenceFrames++
                    if (consecutiveSilenceFrames >= minPauseFrames) {
                        state = State.PAUSE
                        pauseStartTime = timestampMs
                        consecutiveSpeechFrames = 0
                    }
                } else {
                    consecutiveSilenceFrames = 0
                }
            }

            State.PAUSE -> {
                val pauseElapsed = timestampMs - pauseStartTime

                if (isSpeech) {
                    consecutiveSpeechFrames++
                    if (consecutiveSpeechFrames >= minOnsetFrames) {
                        // Speech resumed after pause — this is a WORD BOUNDARY
                        val wordDuration = pauseStartTime - speechStartTime
                        if (wordDuration >= minWordDurationMs) {
                            wordCount++
                            onWordEvent?.invoke(WordEvent.WordAdvance(
                                wordIndex = wordCount,
                                timestampMs = timestampMs,
                                prevWordDurationMs = wordDuration,
                                pauseDurationMs = pauseElapsed
                            ))
                            Log.d(TAG, "WORD ADVANCE to $wordCount (word=${wordDuration}ms, pause=${pauseElapsed}ms)")
                        } else {
                            Log.d(TAG, "Rejected short word (${wordDuration}ms)")
                        }

                        state = State.SPEECH
                        speechStartTime = timestampMs
                        consecutiveSilenceFrames = 0
                    }
                } else {
                    consecutiveSpeechFrames = 0

                    if (pauseElapsed > maxPauseMs) {
                        // Long pause — classify as line break
                        val wordDuration = pauseStartTime - speechStartTime
                        if (wordDuration >= minWordDurationMs) {
                            wordCount++
                            onWordEvent?.invoke(WordEvent.LinePause(
                                wordIndex = wordCount,
                                timestampMs = timestampMs,
                                pauseDurationMs = pauseElapsed
                            ))
                            Log.d(TAG, "LINE PAUSE at word $wordCount (pause=${pauseElapsed}ms)")
                        }

                        state = State.SILENCE
                        consecutiveSpeechFrames = 0
                        consecutiveSilenceFrames = 0
                    }
                }
            }
        }
    }

    private fun computeRMS(frame: ShortArray): Double {
        if (frame.isEmpty()) return 0.0
        return sqrt(frame.map { it.toDouble().pow(2) }.average()) / 32768.0
    }
}

/**
 * Events emitted by the word boundary detector.
 */
sealed class WordEvent {
    /** First word started — user began speaking after silence. */
    data class WordStart(
        val wordIndex: Int,
        val timestampMs: Long,
        val energy: Double
    ) : WordEvent()

    /** Word boundary detected — advanced to the next word. */
    data class WordAdvance(
        val wordIndex: Int,
        val timestampMs: Long,
        val prevWordDurationMs: Long,
        val pauseDurationMs: Long
    ) : WordEvent()

    /** Long pause detected — possibly a line break. */
    data class LinePause(
        val wordIndex: Int,
        val timestampMs: Long,
        val pauseDurationMs: Long
    ) : WordEvent()
}
