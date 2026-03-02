import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private var audioEngine: AudioEngine?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let controller = window?.rootViewController as? FlutterViewController else { return }

    let methodChannel = FlutterMethodChannel(
      name: "com.mantra/audio",
      binaryMessenger: controller.binaryMessenger
    )

    audioEngine = AudioEngine(methodChannel: methodChannel)

    let eventChannel = FlutterEventChannel(
      name: "com.mantra/detections",
      binaryMessenger: controller.binaryMessenger
    )
    // EventChannel stream handler can be added here if needed

    methodChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "start":
        guard let args = call.arguments as? [String: Any],
              let mantras = args["mantras"] as? [[String: Any]],
              let threshold = args["threshold"] as? Double else {
          result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
          return
        }
        self?.audioEngine?.start(mantras: mantras, threshold: Float(threshold))
        result(nil)

      case "stop":
        self?.audioEngine?.stop()
        result(nil)

      case "updateCalibration":
        guard let args = call.arguments as? [String: Any],
              let energy = args["energyThreshold"] as? Double,
              let mean = args["mean"] as? [Double],
              let std = args["std"] as? [Double] else {
          result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
          return
        }
        self?.audioEngine?.updateCalibration(
          energyThreshold: Float(energy),
          mean: mean.map { Float($0) },
          std: std.map { Float($0) }
        )
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
