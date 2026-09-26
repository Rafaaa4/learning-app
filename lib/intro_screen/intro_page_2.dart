import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic Illustration
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppTheme.accent.withOpacity(0.35),
                  Colors.transparent,
                ],
                radius: 0.7,
              ),
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent, Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.4),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.terminal_rounded,
                  size: 68,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
            ),
            child: const Text(
              '💻 Interactive Playground',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          const Text(
            'Write Real Code\nSee Instant Preview',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryDark,
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          const Text(
            'No setup required. Write HTML, CSS, and JavaScript in our built-in code editor. Inspect outputs, catch errors, and test your code on the fly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppTheme.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
