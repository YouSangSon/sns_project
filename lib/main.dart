import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app.dart';
import 'services/supabase_service.dart';
import 'services/api_service.dart';
import 'services/notification_service_onesignal.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize REST API Service
  print('🔧 Initializing REST API Service...');
  ApiService().initialize();

  // Initialize OneSignal Push Notifications
  print('🔔 Initializing OneSignal...');
  try {
    await NotificationServiceOneSignal().initialize();
    print('✅ OneSignal initialized successfully');
  } catch (e) {
    print('⚠️ OneSignal initialization failed: $e');
  }

  // Initialize Supabase (optional - only if configured)
  if (SupabaseConfig.isConfigured) {
    print('🗄️ Initializing Supabase...');
    try {
      await SupabaseService.initialize();
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('⚠️ Supabase initialization failed: $e');
      print('   Continuing without Supabase');
    }
  }

  // Platform-specific initialization
  if (kIsWeb) {
    print('🌐 Running on Web platform');
  } else {
    print('📱 Running on Mobile platform');
  }

  print('🚀 App starting...\n');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
