package com.mantra.mantra.audio

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodChannel
import kotlin.math.*

/**
 * Native audio engine running on a dedicated thread.
 *
 * Pipeline per frame (512 samples @ 16kHz = ~32ms):
 *   1. VAD gate (energy + ZCR) — skip if silence
 *   2. MFCC extraction (pre-emphasis → hamming → FFT → mel filterbank → DCT)
 *   3. TFLite inference → class probabilities
 *   4. If detection above threshold → send event to Flutter via MethodChannel
 */
class AudioEngine(private val methodChannel: MethodChannel) {

    companion object {
        private const val TAG = "AudioEngine"
        private const val SAMPLE_RATE = 16000
        private const val FRAME_SIZE = 512
        private const val MFCC_COEFFICIENTS = 40
        private const val MEL_FILTERS = 40
        private const val PRE_EMPHASIS = 0.97
        private const val MEL_LOW_FREQ = 300.0
        private const val MEL_HIGH_FREQ = 8000.0
    }

    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var handlerThread: HandlerThread? = null
    private var handler: Handler? = null

    private var threshold: Float = 0.82f
    private var backgroundClassIndex: Int = -1

    // Calibration normalization parameters
    private var calibrationMean: FloatArray? = null
    private var calibrationStd: FloatArray? = null

    // Pre-computed mel filterbank matrix
    private lateinit var melFilterbank: Array<DoubleArray>

    // Hamming window coefficients
    private val hammingWindow = DoubleArray(FRAME_SIZE) { n ->
        0.54 - 0.46 * cos(2.0 * PI * n / (FRAME_SIZE - 1))
    }

    fun start(mantras: List<Map<String, Any>>, threshold: Float) {
        if (isRecording) return
        this.threshold = threshold
        this.backgroundClassIndex = mantras.size // last class is background

        // Pre-compute mel filterbank
        melFilterbank = computeMelFilterbank()

        // Set up audio thread
        handlerThread = HandlerThread("AudioEngineThread").also { it.start() }
        handler = Handler(handlerThread!!.looper)

        val bufferSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        ) * 2

        audioRecord = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            SAMPLE_RATE,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            bufferSize
        )

        isRecording = true
        audioRecord?.startRecording()

        handler?.post { recordingLoop() }
        Log.i(TAG, "Audio engine started with threshold=$threshold")
    }

    fun stop() {
        isRecording = false
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        handlerThread?.quitSafely()
        handlerThread = null
        handler = null
        Log.i(TAG, "Audio engine stopped")
    }

    fun updateCalibration(energyThreshold: Float, mean: FloatArray, std: FloatArray) {
        VadGate.updateThresholds(energyThreshold.toDouble(), VadGate.zcrThreshold)
        calibrationMean = mean
        calibrationStd = std
        Log.i(TAG, "Calibration updated: energy=$energyThreshold")
    }

    private fun recordingLoop() {
        val buffer = ShortArray(FRAME_SIZE)
        while (isRecording) {
            val read = audioRecord?.read(buffer, 0, FRAME_SIZE) ?: 0
            if (read != FRAME_SIZE) continue

            // Step 1: VAD gate
            if (!VadGate.isVoiceActive(buffer)) continue

            // Step 2: Extract MFCC
            val mfcc = extractMfcc(buffer)

            // Step 3: Normalize with calibration data
            val normalizedMfcc = normalizeMfcc(mfcc)

            // Step 4: TFLite inference
            // TODO: Replace with actual TFLite interpreter call when model is available
            // val output = runInference(normalizedMfcc)
            // For now, send raw MFCC event for testing
            val output = FloatArray(backgroundClassIndex + 1) // placeholder

            // Step 5: Find best class
            val maxIdx = output.indices.maxByOrNull { output[it] } ?: continue
            val maxConf = output[maxIdx]

            // Step 6: Emit detection if above threshold and not background
            if (maxIdx != backgroundClassIndex && maxConf > threshold) {
                val event = mapOf(
                    "index" to maxIdx,
                    "confidence" to maxConf.toDouble(),
                    "timestamp" to System.currentTimeMillis()
                )
                handler?.post {
                    methodChannel.invokeMethod("onDetection", event)
                }
            }
        }
    }

    // ─── MFCC Pipeline ───

    private fun extractMfcc(frame: ShortArray): FloatArray {
        val samples = DoubleArray(FRAME_SIZE)

        // Pre-emphasis
        samples[0] = frame[0].toDouble()
        for (i in 1 until FRAME_SIZE) {
            samples[i] = frame[i].toDouble() - PRE_EMPHASIS * frame[i - 1].toDouble()
        }

        // Hamming window
        for (i in samples.indices) {
            samples[i] *= hammingWindow[i]
        }

        // FFT (simple DFT for correctness — replace with KissFFT for production speed)
        val fftReal = DoubleArray(FRAME_SIZE)
        val fftImag = DoubleArray(FRAME_SIZE)
        for (k in 0 until FRAME_SIZE / 2 + 1) {
            var real = 0.0
            var imag = 0.0
            for (n in 0 until FRAME_SIZE) {
                val angle = 2.0 * PI * k * n / FRAME_SIZE
                real += samples[n] * cos(angle)
                imag -= samples[n] * sin(angle)
            }
            fftReal[k] = real
            fftImag[k] = imag
        }

        // Power spectrum
        val powerSpectrum = DoubleArray(FRAME_SIZE / 2 + 1) { k ->
            (fftReal[k].pow(2) + fftImag[k].pow(2)) / FRAME_SIZE
        }

        // Apply mel filterbank
        val melEnergies = DoubleArray(MEL_FILTERS) { m ->
            var energy = 0.0
            for (k in powerSpectrum.indices) {
                energy += melFilterbank[m][k] * powerSpectrum[k]
            }
            ln(max(energy, 1e-10))
        }

        // DCT to get MFCC coefficients
        val mfcc = FloatArray(MFCC_COEFFICIENTS)
        for (i in 0 until MFCC_COEFFICIENTS) {
            var sum = 0.0
            for (j in 0 until MEL_FILTERS) {
                sum += melEnergies[j] * cos(PI * i * (2.0 * j + 1) / (2.0 * MEL_FILTERS))
            }
            mfcc[i] = (sum * sqrt(2.0 / MEL_FILTERS)).toFloat()
        }

        return mfcc
    }

    private fun normalizeMfcc(mfcc: FloatArray): FloatArray {
        val mean = calibrationMean ?: return mfcc
        val std = calibrationStd ?: return mfcc
        return FloatArray(mfcc.size) { i ->
            if (std[i] > 1e-6f) (mfcc[i] - mean[i]) / std[i] else 0f
        }
    }

    private fun computeMelFilterbank(): Array<DoubleArray> {
        val nfft = FRAME_SIZE
        val numBins = nfft / 2 + 1

        fun hzToMel(hz: Double) = 2595.0 * log10(1.0 + hz / 700.0)
        fun melToHz(mel: Double) = 700.0 * (10.0.pow(mel / 2595.0) - 1.0)

        val melLow = hzToMel(MEL_LOW_FREQ)
        val melHigh = hzToMel(MEL_HIGH_FREQ)
        val melPoints = DoubleArray(MEL_FILTERS + 2) { i ->
            melToHz(melLow + i * (melHigh - melLow) / (MEL_FILTERS + 1))
        }

        // Convert to FFT bin indices
        val binPoints = IntArray(melPoints.size) { i ->
            ((melPoints[i] * (nfft + 1)) / SAMPLE_RATE).toInt()
        }

        return Array(MEL_FILTERS) { m ->
            val filter = DoubleArray(numBins)
            for (k in binPoints[m]..minOf(binPoints[m + 1], numBins - 1)) {
                filter[k] = (k - binPoints[m]).toDouble() / (binPoints[m + 1] - binPoints[m]).toDouble()
            }
            for (k in binPoints[m + 1]..minOf(binPoints[m + 2], numBins - 1)) {
                filter[k] = (binPoints[m + 2] - k).toDouble() / (binPoints[m + 2] - binPoints[m + 1]).toDouble()
            }
            filter
        }
    }
}
