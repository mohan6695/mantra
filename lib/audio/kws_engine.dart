/// Placeholder for future TFLite-based keyword spotting engine.
/// Currently using amplitude-based detection on the native side.
class KWSEngine {
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// No-op for now. Will load TFLite model in the future.
  Future<void> loadModel() async {
    _isLoaded = false;
  }

  /// Returns empty confidence list — detection happens natively.
  List<double> infer(List<double> mfccFrame) {
    return [];
  }

  void dispose() {
    _isLoaded = false;
  }
}
