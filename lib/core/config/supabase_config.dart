/// Supabase Configuration
///
/// To use Supabase:
/// 1. Create a project at https://supabase.com
/// 2. Get your project URL and anon key from Project Settings > API
/// 3. Replace the values below
///
/// Example:
/// const supabaseUrl = 'https://your-project.supabase.co';
/// const supabaseAnonKey = 'your-anon-key';

class SupabaseConfig {
  // TODO: Replace with your Supabase project credentials
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );

  // Check if Supabase is configured
  static bool get isConfigured =>
      supabaseUrl != 'https://your-project.supabase.co' &&
      supabaseAnonKey != 'your-anon-key-here';
}
