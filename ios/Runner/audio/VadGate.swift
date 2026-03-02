import Foundation
import Accelerate

/// Voice Activity Detection gate using energy and zero-crossing rate.
/// Filters out silence and non-speech audio before expensive KWS inference.
class VadGate {
    var energyThreshold: Double = 0.01
    var zcrThreshold: Double = 0.30

    /// Returns true if the audio frame likely contains voice.
    func isVoiceActive(frame: [Float]) -> Bool {
        guard !frame.isEmpty else { return false }

        // RMS energy (using vDSP for speed)
        var energy: Float = 0
        vDSP_measqv(frame, 1, &energy, vDSP_Length(frame.count))
        let normalizedEnergy = Double(energy) / (32768.0 * 32768.0)

        // Zero-crossing rate
        var crossings = 0
        for i in 1..<frame.count {
            if (frame[i] >= 0) != (frame[i - 1] >= 0) {
                crossings += 1
            }
        }
        let zcr = Double(crossings) / Double(frame.count)

        return normalizedEnergy > energyThreshold && zcr < zcrThreshold
    }

    func updateThresholds(energy: Double, zcr: Double) {
        energyThreshold = energy
        zcrThreshold = zcr
    }
}
