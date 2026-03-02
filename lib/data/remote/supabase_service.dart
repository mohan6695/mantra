import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper around Supabase auth for the mantra counter app.
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ──────────────────────────────────────────────

  static bool get isAuthenticated =>
      _client.auth.currentSession != null;

  static User? get currentUser => _client.auth.currentUser;

  static String? get accessToken =>
      _client.auth.currentSession?.accessToken;

  /// Email + password sign-up. Creates user & profile row.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );
    // Create profile row
    if (res.user != null) {
      await _client.from('profiles').upsert({
        'id': res.user!.id,
        'display_name': displayName ?? email.split('@').first,
      });
    }
    return res;
  }

  /// Email + password sign-in.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Google OAuth.
  static Future<bool> signInWithGoogle() async {
    final res = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.mantra.mantra://callback',
    );
    return res;
  }

  /// Apple OAuth (iOS).
  static Future<bool> signInWithApple() async {
    final res = await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.mantra.mantra://callback',
    );
    return res;
  }

  /// Sign out.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Profile ───────────────────────────────────────────

  /// Fetch the current user's server profile.
  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final res =
        await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    return res;
  }

  /// Update the current user's profile fields.
  static Future<void> updateProfile(Map<String, dynamic> fields) async {
    final user = currentUser;
    if (user == null) return;
    await _client.from('profiles').update(fields).eq('id', user.id);
  }
}
