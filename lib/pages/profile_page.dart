import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/supabase_sync_service.dart';
import '../services/notification_service.dart';
import '../data/models/progress.dart';
import 'LoginPage.dart';
import 'tools_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final SupabaseSyncService _syncService = SupabaseSyncService();
  final NotificationService _notificationService = NotificationService();
  
  UserProgress _progress = UserProgress();
  bool _isLoading = true;
  bool _isSyncing = false;

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

  Future<void> _handleSync() async {
    if (!_authService.isAuthenticated) {
      _showInfoDialog(
        'Guest Mode',
        'Please sign in to sync your course progress and achievements to the cloud.',
        actionText: 'Sign In',
        onAction: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()));
        },
      );
      return;
    }

    setState(() => _isSyncing = true);
    try {
      await _syncService.syncLocalToCloud();
      final updated = await _syncService.syncCloudToLocal();
      if (mounted) {
        setState(() => _progress = updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully synced progress with Supabase cloud!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Log Out', style: TextStyle(color: AppTheme.textPrimaryDark)),
        content: const Text('Are you sure you want to log out of your account?', style: TextStyle(color: AppTheme.textSecondaryDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMutedDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final userEmail = currentUser?.email ?? 'Guest Learner';
    final userFullName = currentUser?.userMetadata?['full_name'] as String? ?? 'Code Adventurer';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: _isSyncing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary))
                        : const Icon(Icons.sync_rounded, color: AppTheme.primary),
                      onPressed: _isSyncing ? null : _handleSync,
                      tooltip: 'Sync Cloud Progress',
                    ),
                  ],
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
                    userFullName,
                    style: const TextStyle(
                      color: AppTheme.textPrimaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    userEmail,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryDark,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Level ${_progress.userLevel} Developer',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
                _buildSettingsTile(Icons.cloud_sync_rounded, 'Sync with Supabase Cloud', onTap: _handleSync),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.notifications_rounded, 'Notifications', onTap: _testNotification),
                const SizedBox(height: 12),
                _buildSettingsTile(Icons.build_rounded, 'Developer Tools', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ToolsPage()));
                }),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  Icons.logout_rounded, 
                  _authService.isAuthenticated ? 'Log Out' : 'Sign In', 
                  color: _authService.isAuthenticated ? AppTheme.error : AppTheme.primary, 
                  onTap: () {
                    if (_authService.isAuthenticated) {
                      _handleLogout();
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()));
                    }
                  }
                ),
              ],
            ),
      ),
    );
  }

  void _showInfoDialog(String title, String content, {String? actionText, VoidCallback? onAction}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimaryDark)),
        content: Text(content, style: const TextStyle(color: AppTheme.textSecondaryDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppTheme.textMutedDark)),
          ),
          if (actionText != null && onAction != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onAction();
              },
              child: Text(actionText),
            ),
        ],
      ),
    );
  }

  Future<void> _testNotification() async {
    final hasPermission = await _notificationService.requestPermission();
    if (!mounted) return;
    if (hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission granted! Sending test notification in 3s...'),
          backgroundColor: AppTheme.success,
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      await _notificationService.showNotification(
        title: 'Learnpg',
        body: 'Keep up your coding streak today!',
      );
    } else {
      if (!mounted) return;
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
