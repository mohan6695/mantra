/// Environment variables injected at build time via --dart-define.
/// Run with:
///   flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx ...
class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const cfWorkerBaseUrl = String.fromEnvironment('CF_WORKER_URL');
  static const r2ModelBaseUrl = String.fromEnvironment('R2_MODEL_URL');
}
