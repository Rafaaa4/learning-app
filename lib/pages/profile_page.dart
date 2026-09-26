import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../data/models/progress.dart';
import 'tools_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
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
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Level is measured by earning 100 XP per level.',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryDark,
                      fontSize: 12,
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
                      child: _buildStatCard('Total XP', '${_progress.totalXp}', Icons.bolt_rounded, Colors.amber, () {
                        _showInfoDialog('Total XP', 'You have earned ${_progress.totalXp} XP in total. Keep completing lessons to earn more!');
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard('Streak', '${_progress.streakDays} Days', Icons.local_fire_department_rounded, Colors.orange, () {
                        _showInfoDialog('Streak', 'You are on a ${_progress.streakDays} day streak! Code every day to keep it going.');
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildSettingsTile(Icons.settings_rounded, 'Settings', onTap: () {
                  _showInfoDialog('Settings', 'Settings functionality is coming soon.');
                }),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.notifications_rounded, 'Notifications', onTap: () {
                  _testNotification();
                }),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.build_rounded, 'Developer Tools', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ToolsPage()));
                }),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.help_rounded, 'Help & Support', onTap: () {
                  _showInfoDialog('Help & Support', 'Help and support functionality is coming soon.');
                }),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.logout_rounded, 'Log Out', color: AppTheme.error, onTap: () {
                  _showInfoDialog('Log Out', 'You have been logged out.');
                }),
              ],
            ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimaryDark)),
        content: Text(content, style: const TextStyle(color: AppTheme.textSecondaryDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _testNotification() async {
    final hasPermission = await _notificationService.requestPermission();
    if (hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission granted! Sending a test notification in 3 seconds...'),
          backgroundColor: AppTheme.success,
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      await _notificationService.showNotification(
        title: 'Learnpg',
        body: 'This is a test notification from your app!',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission denied.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {Color color = AppTheme.textPrimaryDark, required VoidCallback onTap}) {
    return Material(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.cardBorderDark),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }
}
