import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app.dart';
import 'services/supabase_service.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase (optional - only if configured)
  if (SupabaseConfig.isConfigured) {
    try {
      await SupabaseService.initialize();
    } catch (e) {
      print('⚠️ Supabase initialization failed: $e');
      print('   Continuing with Firebase only');
    }
  }

  // Platform-specific initialization
  if (kIsWeb) {
    print('🌐 Running on Web platform');
  } else {
    print('📱 Running on Mobile platform');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
