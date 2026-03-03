package com.mantra.mantra

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.mantra.mantra.audio.AudioEngine
import com.mantra.mantra.audio.VerseAudioEngine

class MainActivity : FlutterActivity() {

    private lateinit var audioEngine: AudioEngine
    private lateinit var verseEngine: VerseAudioEngine

    companion object {
        private const val AUDIO_METHOD_CHANNEL = "com.mantra/audio"
        private const val AUDIO_EVENT_CHANNEL = "com.mantra/detections"
        private const val VERSE_METHOD_CHANNEL = "com.mantra/verse_audio"
        private const val VERSE_EVENT_CHANNEL = "com.mantra/verse_events"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        audioEngine = AudioEngine()
        verseEngine = VerseAudioEngine()

        // ── Existing mantra repetition channels ─────────────────

        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_METHOD_CHANNEL
        )

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                audioEngine.eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                audioEngine.eventSink = null
            }
        })

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    @Suppress("UNCHECKED_CAST")
                    val mantras = call.argument<List<Map<String, Any>>>("mantras") ?: emptyList()
                    val threshold = call.argument<Double>("threshold")?.toFloat() ?: 0.82f
                    audioEngine.start(mantras, threshold)
                    result.success(null)
                }
                "stop" -> {
                    audioEngine.stop()
                    result.success(null)
                }
                "updateCalibration" -> {
                    val energy = call.argument<Double>("energyThreshold")?.toFloat() ?: 0.01f
                    val refractoryMs = call.argument<Int>("refractoryMs") ?: 800
                    audioEngine.updateCalibration(energy, refractoryMs)
                    result.success(null)
                }
                "startBuffering" -> {
                    audioEngine.bufferManager.startBuffering()
                    result.success(null)
                }
                "flushBuffer" -> {
                    val wav = audioEngine.bufferManager.flushAsWav()
                    result.success(wav)
                }
                "stopBuffering" -> {
                    audioEngine.bufferManager.stopBuffering()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ── Verse tracking channels ─────────────────────────────

        val verseMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            VERSE_METHOD_CHANNEL
        )

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            VERSE_EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                verseEngine.eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                verseEngine.eventSink = null
            }
        })

        verseMethodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startVerse" -> {
                    val totalWords = call.argument<Int>("totalWords") ?: 0
                    val sensitivity = call.argument<Double>("sensitivity") ?: 0.5
                    verseEngine.start(totalWords, sensitivity)
                    result.success(null)
                }
                "stopVerse" -> {
                    verseEngine.stop()
                    result.success(null)
                }
                "updateSensitivity" -> {
                    val sensitivity = call.argument<Double>("sensitivity") ?: 0.5
                    verseEngine.updateSensitivity(sensitivity)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        audioEngine.stop()
        verseEngine.stop()
        super.onDestroy()
    }
}
