import 'package:flutter/material.dart';
import 'pages/WelcomeScreen.dart';
import 'pages/LoginPage.dart';
import 'pages/SignUpPage.dart';
import 'pages/main_layout.dart';
import 'features/playground/code_playground_page.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String playground = '/playground';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginPage(),
        signup: (context) => const SignUpPage(),
        home: (context) => const MainLayout(),
        playground: (context) => const CodePlaygroundPage(),
      };
}
