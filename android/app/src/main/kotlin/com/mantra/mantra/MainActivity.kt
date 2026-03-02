package com.mantra.mantra

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.mantra.mantra.audio.AudioEngine

class MainActivity : FlutterActivity() {

    private lateinit var audioEngine: AudioEngine
    private var detectionEventSink: EventChannel.EventSink? = null

    companion object {
        private const val AUDIO_METHOD_CHANNEL = "com.mantra/audio"
        private const val AUDIO_EVENT_CHANNEL = "com.mantra/detections"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_METHOD_CHANNEL
        )

        // Create audio engine with a proxy channel that forwards to EventSink
        val proxyChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_METHOD_CHANNEL
        )
        audioEngine = AudioEngine(proxyChannel)

        // Set up EventChannel for streaming detections to Dart
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            AUDIO_EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                detectionEventSink = events
            }
            override fun onCancel(arguments: Any?) {
                detectionEventSink = null
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
                    @Suppress("UNCHECKED_CAST")
                    val meanList = call.argument<List<Double>>("mean") ?: emptyList()
                    @Suppress("UNCHECKED_CAST")
                    val stdList = call.argument<List<Double>>("std") ?: emptyList()
                    audioEngine.updateCalibration(
                        energy,
                        meanList.map { it.toFloat() }.toFloatArray(),
                        stdList.map { it.toFloat() }.toFloatArray()
                    )
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

