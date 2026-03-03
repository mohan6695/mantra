// Supabase removed for local-only build. Will be re-enabled later.

/// Stub wrapper — cloud auth disabled for local-only build.
class SupabaseService {
  static bool get isAuthenticated => false;
  static String? get accessToken => null;
  static Future<void> signOut() async {}
}
