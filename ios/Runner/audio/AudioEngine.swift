import AVFoundation
import Accelerate
import Flutter

/// Native audio engine for iOS using AVAudioEngine.
///
/// Pipeline per frame (512 samples @ 16kHz = ~32ms):
///   1. VAD gate (energy + ZCR) — skip if silence
///   2. MFCC extraction (pre-emphasis → hamming → FFT → mel filterbank → DCT)
///   3. TFLite inference → class probabilities
///   4. If detection above threshold → send event to Flutter via MethodChannel
class AudioEngine: NSObject {

    private static let sampleRate: Double = 16000
    private static let frameSize: Int = 512
    private static let mfccCoefficients: Int = 40
    private static let melFilters: Int = 40
    private static let preEmphasis: Float = 0.97
    private static let melLowFreq: Double = 300.0
    private static let melHighFreq: Double = 8000.0

    private let methodChannel: FlutterMethodChannel
    private let vadGate = VadGate()
    private var audioEngine: AVAudioEngine?
    private var isRunning = false

    private var threshold: Float = 0.82
    private var backgroundClassIndex: Int = -1

    private var calibrationMean: [Float]?
    private var calibrationStd: [Float]?

    // Pre-computed
    private var melFilterbank: [[Float]] = []
    private var hammingWindow: [Float] = []

    init(methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
        super.init()
        computeHammingWindow()
    }

    func start(mantras: [[String: Any]], threshold: Float) {
        guard !isRunning else { return }
        self.threshold = threshold
        self.backgroundClassIndex = mantras.count

        melFilterbank = computeMelFilterbank()

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [])
            try session.setPreferredSampleRate(AudioEngine.sampleRate)
            try session.setActive(true)
        } catch {
            print("AudioEngine: Failed to configure audio session: \(error)")
            return
        }

        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }

        let inputNode = engine.inputNode
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: AudioEngine.sampleRate,
            channels: 1,
            interleaved: false
        )!

        inputNode.installTap(
            onBus: 0,
            bufferSize: UInt32(AudioEngine.frameSize),
            format: format
        ) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        do {
            try engine.start()
            isRunning = true
            print("AudioEngine: Started with threshold=\(threshold)")
        } catch {
            print("AudioEngine: Failed to start: \(error)")
        }
    }

    func stop() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        isRunning = false
        print("AudioEngine: Stopped")
    }

    func updateCalibration(energyThreshold: Float, mean: [Float], std: [Float]) {
        vadGate.updateThresholds(energy: Double(energyThreshold), zcr: vadGate.zcrThreshold)
        calibrationMean = mean
        calibrationStd = std
    }

    // MARK: - Audio processing

    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        let frame = Array(UnsafeBufferPointer(start: channelData, count: frameCount))

        guard frame.count >= AudioEngine.frameSize else { return }
        let samples = Array(frame.prefix(AudioEngine.frameSize))

        // Step 1: VAD gate
        guard vadGate.isVoiceActive(frame: samples) else { return }

        // Step 2: Extract MFCC
        let mfcc = extractMfcc(frame: samples)

        // Step 3: Normalize
        let normalizedMfcc = normalizeMfcc(mfcc)

        // Step 4: TFLite inference
        // TODO: Replace with actual TFLite interpreter call when model is available
        let output = [Float](repeating: 0, count: backgroundClassIndex + 1)

        // Step 5: Find best class
        guard let maxIdx = output.indices.max(by: { output[$0] < output[$1] }) else { return }
        let maxConf = output[maxIdx]

        // Step 6: Emit detection if above threshold and not background
        if maxIdx != backgroundClassIndex && maxConf > threshold {
            let event: [String: Any] = [
                "index": maxIdx,
                "confidence": Double(maxConf),
                "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
            ]
            DispatchQueue.main.async { [weak self] in
                self?.methodChannel.invokeMethod("onDetection", arguments: event)
            }
        }
    }

    // MARK: - MFCC Pipeline

    private func extractMfcc(frame: [Float]) -> [Float] {
        var samples = [Float](repeating: 0, count: AudioEngine.frameSize)

        // Pre-emphasis
        samples[0] = frame[0]
        for i in 1..<AudioEngine.frameSize {
            samples[i] = frame[i] - AudioEngine.preEmphasis * frame[i - 1]
        }

        // Hamming window (using vDSP)
        vDSP_vmul(samples, 1, hammingWindow, 1, &samples, 1, vDSP_Length(AudioEngine.frameSize))

        // FFT using Accelerate
        let log2n = vDSP_Length(log2(Float(AudioEngine.frameSize)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else { return [] }
        defer { vDSP_destroy_fftsetup(fftSetup) }

        var realPart = [Float](repeating: 0, count: AudioEngine.frameSize / 2)
        var imagPart = [Float](repeating: 0, count: AudioEngine.frameSize / 2)

        // Pack into split complex
        samples.withUnsafeBufferPointer { ptr in
            ptr.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: AudioEngine.frameSize / 2) { complexPtr in
                var splitComplex = DSPSplitComplex(realp: &realPart, imagp: &imagPart)
                vDSP_ctoz(complexPtr, 2, &splitComplex, 1, vDSP_Length(AudioEngine.frameSize / 2))
            }
        }

        var splitComplex = DSPSplitComplex(realp: &realPart, imagp: &imagPart)
        vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(kFFTDirection_Forward))

        // Power spectrum
        let numBins = AudioEngine.frameSize / 2 + 1
        var powerSpectrum = [Float](repeating: 0, count: numBins)
        for k in 0..<min(numBins, realPart.count) {
            powerSpectrum[k] = (realPart[k] * realPart[k] + imagPart[k] * imagPart[k]) / Float(AudioEngine.frameSize)
        }

        // Mel filterbank
        var melEnergies = [Float](repeating: 0, count: AudioEngine.melFilters)
        for m in 0..<AudioEngine.melFilters {
            var energy: Float = 0
            for k in 0..<min(powerSpectrum.count, melFilterbank[m].count) {
                energy += melFilterbank[m][k] * powerSpectrum[k]
            }
            melEnergies[m] = logf(max(energy, 1e-10))
        }

        // DCT → MFCC
        var mfcc = [Float](repeating: 0, count: AudioEngine.mfccCoefficients)
        for i in 0..<AudioEngine.mfccCoefficients {
            var sum: Float = 0
            for j in 0..<AudioEngine.melFilters {
                sum += melEnergies[j] * cosf(Float.pi * Float(i) * (2.0 * Float(j) + 1.0) / (2.0 * Float(AudioEngine.melFilters)))
            }
            mfcc[i] = sum * sqrtf(2.0 / Float(AudioEngine.melFilters))
        }

        return mfcc
    }

    private func normalizeMfcc(_ mfcc: [Float]) -> [Float] {
        guard let mean = calibrationMean, let std = calibrationStd else { return mfcc }
        return mfcc.enumerated().map { (i, val_) in
            std[i] > 1e-6 ? (val_ - mean[i]) / std[i] : 0
        }
    }

    // MARK: - Pre-computation

    private func computeHammingWindow() {
        hammingWindow = (0..<AudioEngine.frameSize).map { n in
            Float(0.54 - 0.46 * cos(2.0 * Double.pi * Double(n) / Double(AudioEngine.frameSize - 1)))
        }
    }

    private func computeMelFilterbank() -> [[Float]] {
        let nfft = AudioEngine.frameSize
        let numBins = nfft / 2 + 1

        func hzToMel(_ hz: Double) -> Double { 2595.0 * log10(1.0 + hz / 700.0) }
        func melToHz(_ mel: Double) -> Double { 700.0 * (pow(10.0, mel / 2595.0) - 1.0) }

        let melLow = hzToMel(AudioEngine.melLowFreq)
        let melHigh = hzToMel(AudioEngine.melHighFreq)
        let melPoints = (0..<AudioEngine.melFilters + 2).map { i in
            melToHz(melLow + Double(i) * (melHigh - melLow) / Double(AudioEngine.melFilters + 1))
        }
        let binPoints = melPoints.map { Int(($0 * Double(nfft + 1)) / AudioEngine.sampleRate) }

        return (0..<AudioEngine.melFilters).map { m in
            var filter = [Float](repeating: 0, count: numBins)
            for k in binPoints[m]...min(binPoints[m + 1], numBins - 1) {
                let denom = binPoints[m + 1] - binPoints[m]
                if denom > 0 {
                    filter[k] = Float(k - binPoints[m]) / Float(denom)
                }
            }
            for k in binPoints[m + 1]...min(binPoints[m + 2], numBins - 1) {
                let denom = binPoints[m + 2] - binPoints[m + 1]
                if denom > 0 {
                    filter[k] = Float(binPoints[m + 2] - k) / Float(denom)
                }
            }
            return filter
        }
    }
}
