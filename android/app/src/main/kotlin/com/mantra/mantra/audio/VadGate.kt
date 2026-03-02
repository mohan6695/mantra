package com.mantra.mantra.audio

import kotlin.math.pow

/**
 * Voice Activity Detection gate using energy and zero-crossing rate.
 * Filters out silence and non-speech audio before expensive KWS inference.
 */
object VadGate {
    var energyThreshold: Double = 0.01
    var zcrThreshold: Double = 0.30

    /**
     * Returns true if the audio frame likely contains voice.
     * - Energy check: RMS energy must exceed threshold (filters silence).
     * - ZCR check: Zero-crossing rate must be below threshold
     *   (speech has lower ZCR than noise/TV).
     */
    fun isVoiceActive(frame: ShortArray): Boolean {
        if (frame.isEmpty()) return false

        // Normalized energy: average of squared samples / max^2
        val energy = frame.map { it.toDouble().pow(2) }.average() / 32768.0.pow(2)

        // Zero-crossing rate: fraction of sign changes
        val zcr = frame.toList()
            .zipWithNext()
            .count { (a, b) -> (a >= 0) != (b >= 0) }
            .toDouble() / frame.size

        return energy > energyThreshold && zcr < zcrThreshold
    }

    fun updateThresholds(energy: Double, zcr: Double) {
        energyThreshold = energy
        zcrThreshold = zcr
    }
}
