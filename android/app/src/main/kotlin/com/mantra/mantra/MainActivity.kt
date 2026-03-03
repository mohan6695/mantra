package com.mantra.mantra

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.mantra.mantra.audio.AudioEngine

class MainActivity : FlutterActivity() {

    private lateinit var audioEngine: AudioEngine

    companion object {
        private const val AUDIO_METHOD_CHANNEL = "com.mantra/audio"
        private const val AUDIO_EVENT_CHANNEL = "com.mantra/detections"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        audioEngine = AudioEngine()

        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_METHOD_CHANNEL
        )

        // Set up EventChannel for streaming detections to Dart
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
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        audioEngine.stop()
        super.onDestroy()
    }
}
