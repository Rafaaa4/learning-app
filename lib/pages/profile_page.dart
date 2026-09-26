import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/storage_service.dart';
import '../data/models/progress.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StorageService _storageService = StorageService();
  UserProgress _progress = UserProgress();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storageService.init();
    final progress = _storageService.getProgress();
    if (mounted) {
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 100), // padding bottom باش ميتغطاش بالـ Nav bar
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.cardDark,
                      child: Icon(Icons.person_rounded, size: 50, color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Level ${_progress.userLevel} Developer',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Your Stats',
                  style: TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Total XP', '${_progress.totalXp}', Icons.bolt_rounded, Colors.amber),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard('Streak', '${_progress.streakDays} Days', Icons.local_fire_department_rounded, Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildSettingsTile(Icons.settings_rounded, 'Settings'),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.notifications_rounded, 'Notifications'),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.help_rounded, 'Help & Support'),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.logout_rounded, 'Log Out', color: AppTheme.error),
              ],
            ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorderDark),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: AppTheme.textPrimaryDark, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {Color color = AppTheme.textPrimaryDark}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorderDark),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () {
          // Action هنا
        },
      ),
    );
  }
}
