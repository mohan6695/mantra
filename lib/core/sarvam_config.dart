/// Sarvam.ai API configuration and key management.
///
/// Uses SharedPreferences for API key storage.
/// Free credits: ₹1000 per new account.
/// Pricing: ₹30/hour for STT.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ──────────────────────────────────────────────────────────
// Constants
// ──────────────────────────────────────────────────────────

class SarvamConstants {
  SarvamConstants._();

  static const String restEndpoint = 'https://api.sarvam.ai/speech-to-text';
  static const String wsEndpoint = 'wss://api.sarvam.ai/speech-to-text/ws';
  static const String translateWsEndpoint =
      'wss://api.sarvam.ai/speech-to-text-translate/ws';

  /// Supported language codes for mantras.
  static const String sanskrit = 'sa-IN';
  static const String hindi = 'hi-IN';
  static const String tamil = 'ta-IN';
  static const String telugu = 'te-IN';
  static const String kannada = 'kn-IN';
  static const String malayalam = 'ml-IN';
  static const String bengali = 'bn-IN';
  static const String marathi = 'mr-IN';
  static const String gujarati = 'gu-IN';
  static const String punjabi = 'pa-IN';
  static const String english = 'en-IN';

  static const String defaultModel = 'saaras:v3';
  static const String defaultMode = 'verbatim';

  static const String _apiKeyPref = 'sarvam_api_key';
  static const String _enabledPref = 'sarvam_enabled';
  static const String _usagePref = 'sarvam_usage_seconds';

  /// Auto-detect language.
  static const String autoDetect = 'unknown';
}

// ──────────────────────────────────────────────────────────
// Sarvam configuration state
// ──────────────────────────────────────────────────────────

class SarvamConfig {
  final String? apiKey;
  final bool isEnabled;
  final int usageSeconds;
  final String languageCode;
  final String model;
  final String mode;

  const SarvamConfig({
    this.apiKey,
    this.isEnabled = false,
    this.usageSeconds = 0,
    this.languageCode = SarvamConstants.hindi,
    this.model = SarvamConstants.defaultModel,
    this.mode = SarvamConstants.defaultMode,
  });

  bool get hasValidKey => apiKey != null && apiKey!.isNotEmpty;
  bool get isReady => hasValidKey && isEnabled;

  /// Estimated cost at ₹30/hour.
  double get estimatedCostRupees => (usageSeconds / 3600) * 30;

  SarvamConfig copyWith({
    String? apiKey,
    bool? isEnabled,
    int? usageSeconds,
    String? languageCode,
    String? model,
    String? mode,
  }) {
    return SarvamConfig(
      apiKey: apiKey ?? this.apiKey,
      isEnabled: isEnabled ?? this.isEnabled,
      usageSeconds: usageSeconds ?? this.usageSeconds,
      languageCode: languageCode ?? this.languageCode,
      model: model ?? this.model,
      mode: mode ?? this.mode,
    );
  }
}

// ──────────────────────────────────────────────────────────
// Config notifier with persistence
// ──────────────────────────────────────────────────────────

final sarvamConfigProvider =
    StateNotifierProvider<SarvamConfigNotifier, SarvamConfig>((ref) {
  return SarvamConfigNotifier();
});

class SarvamConfigNotifier extends StateNotifier<SarvamConfig> {
  SarvamConfigNotifier() : super(const SarvamConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SarvamConfig(
      apiKey: prefs.getString(SarvamConstants._apiKeyPref),
      isEnabled: prefs.getBool(SarvamConstants._enabledPref) ?? false,
      usageSeconds: prefs.getInt(SarvamConstants._usagePref) ?? 0,
    );
  }

  Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SarvamConstants._apiKeyPref, key);
    state = state.copyWith(apiKey: key);
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SarvamConstants._enabledPref, enabled);
    state = state.copyWith(isEnabled: enabled);
  }

  Future<void> addUsage(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final newTotal = state.usageSeconds + seconds;
    await prefs.setInt(SarvamConstants._usagePref, newTotal);
    state = state.copyWith(usageSeconds: newTotal);
  }

  Future<void> setLanguage(String languageCode) async {
    state = state.copyWith(languageCode: languageCode);
  }
}
