import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/datasources/supabase_courses_datasource.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final SupabaseCoursesDataSource _coursesDataSource = SupabaseCoursesDataSource();
  bool _isSeeding = false;

  Future<void> _seedCourses() async {
    setState(() => _isSeeding = true);
    try {
      final count = await _coursesDataSource.seedLocalCoursesToSupabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully seeded $count courses (310 lessons) to Supabase DB!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to seed courses to Supabase: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimaryDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
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
              'Manage database seeding, resources, and utilities.',
              style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            _buildSectionTitle('Database Management'),
            const SizedBox(height: 16),
            _buildToolCard(
              title: _isSeeding ? 'Seeding Courses...' : 'Push All Courses to Supabase DB',
              description: 'Migrate all 6 course tracks (310 lessons) into Supabase table courses_db.',
              icon: _isSeeding ? Icons.hourglass_top_rounded : Icons.cloud_upload_rounded,
              color: AppTheme.primary,
              onTap: _isSeeding ? () {} : _seedCourses,
            ),

            const SizedBox(height: 24),
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
                color: color.withValues(alpha: 0.15),
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
