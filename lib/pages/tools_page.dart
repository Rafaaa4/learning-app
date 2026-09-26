import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
          children: [
            const Text(
              'Developer Tools',
              style: TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Everything you need to level up your coding skills.',
              style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            _buildSectionTitle('Daily Challenges'),
            const SizedBox(height: 16),
            _buildToolCard(
              title: 'Algorithm Master',
              description: 'Solve daily coding problems to earn bonus XP.',
              icon: Icons.emoji_events_rounded,
              color: Colors.amber,
              onTap: () {},
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Resources'),
            const SizedBox(height: 16),
            _buildToolCard(
              title: 'Code Snippets Library',
              description: 'Explore useful HTML, CSS, and Dart templates.',
              icon: Icons.data_object_rounded,
              color: const Color(0xFF10B981), // Emerald
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildToolCard(
              title: 'Tech Glossary',
              description: 'Dictionary of programming terms and concepts.',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF8B5CF6), // Violet
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildToolCard(
              title: 'Color Palette Generator',
              description: 'Find the perfect colors for your UI projects.',
              icon: Icons.color_lens_rounded,
              color: const Color(0xFFEC4899), // Pink
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorderDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedDark),
          ],
        ),
      ),
    );
  }
}
