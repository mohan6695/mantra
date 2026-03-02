import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';

/// Handles TFLite model loading, inference, and model update logic.
class KWSEngine {
  Interpreter? _interpreter;
  bool _isLoaded = false;
  int _numClasses = 6; // N mantras + 1 background

  bool get isLoaded => _isLoaded;

  /// Load the KWS model. Prefers a downloaded version over the bundled asset.
  Future<void> loadModel() async {
    // First try local file (downloaded from CF R2)
    final appDir = await getApplicationDocumentsDirectory();
    final modelFile = File('${appDir.path}/models/kws.tflite');

    try {
      if (await modelFile.exists()) {
        _interpreter = Interpreter.fromFile(modelFile);
      } else {
        // Fall back to bundled asset (older version, may not exist yet)
        _interpreter = await Interpreter.fromAsset(AppConstants.modelAsset);
      }

      // Read output shape to determine number of classes
      final outputTensors = _interpreter!.getOutputTensors();
      if (outputTensors.isNotEmpty) {
        _numClasses = outputTensors.first.shape.last;
      }

      _isLoaded = true;
    } catch (e) {
      // Model not available yet — engine will be loaded later
      _isLoaded = false;
    }
  }

  /// Run inference on a single MFCC frame.
  /// Returns a list of confidence values per class.
  List<double> infer(List<double> mfccFrame) {
    if (!_isLoaded || _interpreter == null) {
      return List.filled(_numClasses, 0.0);
    }

    final input = [mfccFrame]; // shape [1, 40]
    final output = List.generate(1, (_) => List.filled(_numClasses, 0.0));
    _interpreter!.run(input, output);
    return output.first;
  }

  /// Check remote for model update and download if available.
  /// Downloads new model to appDir/models/ and atomically replaces current.
  Future<bool> checkAndUpdateModel(
      String remoteVersion, String downloadUrl) async {
    // TODO: Implement:
    // 1. HTTP GET downloadUrl → save to temp file
    // 2. Verify SHA256 hash
    // 3. Atomically move to final path
    // 4. Reload interpreter from new file
    return false;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
