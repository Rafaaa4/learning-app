import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/supabase_constants.dart';
import 'services/storage_service.dart';
import 'pages/WelcomeScreen.dart';
import 'pages/main_layout.dart';
import 'route.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase Client
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  final storageService = StorageService();
  await storageService.init();

  // Initialize notifications & triggers
  final notifService = NotificationService();
  await notifService.init();
  await notifService.requestPermission();
  await notifService.checkInactivityAndRemind();
  await notifService.checkForNewContentUpdates();

  runApp(MainApp(hasSeenOnboarding: storageService.hasSeenOnboarding()));
}

class MainApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MainApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnpg',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: hasSeenOnboarding ? const MainLayout() : const WelcomeScreen(),
      routes: AppRoutes.routes,
    );
  }
}