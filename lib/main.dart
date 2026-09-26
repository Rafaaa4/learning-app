import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'pages/WelcomeScreen.dart';
import 'pages/main_layout.dart';
import 'route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();

  runApp(MainApp(hasSeenOnboarding: storageService.hasSeenOnboarding()));
}

class MainApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MainApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Course Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: hasSeenOnboarding ? const MainLayout() : const WelcomeScreen(),
      routes: AppRoutes.routes,
    );
  }
}