import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

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
                  AppTheme.success.withOpacity(0.35),
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
                    colors: [AppTheme.success, Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.4),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
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
              color: AppTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success.withOpacity(0.4)),
            ),
            child: const Text(
              '⚡ Rule-Based Validation & XP',
              style: TextStyle(
                color: AppTheme.success,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          const Text(
            'Instant Automated Feedback\nEarn XP & Level Up',
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
            'No more manual grading. Get instant validation, actionable tips, and hints .',
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
