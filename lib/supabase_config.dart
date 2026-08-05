import 'package:supabase_flutter/supabase_flutter.dart';

// Re-exported so callers get PostgresChangeEvent, filters etc. alongside the
// client without each importing the package directly.
export 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = 'https://btqapoerqasoowntuxsk.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0cWFwb2VycWFzb293bnR1eHNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU4NDA2NzUsImV4cCI6MjEwMTQxNjY3NX0.4Zsfptu9ZLPzxUCCDaIjIAiTpCegZLT9nCQSsgWnb_w';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
