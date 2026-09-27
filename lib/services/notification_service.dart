import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/supabase_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
    _isInitialized = true;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    await init();
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'tech_academy_channel',
      'Tech Academy Notifications',
      channelDescription: 'Notifications for reminders and updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  /// Check user last visit time & send reminder if 1 day passed
  Future<void> checkInactivityAndRemind() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVisitMillis = prefs.getInt('last_app_visit_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastVisitMillis > 0) {
      final difference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastVisitMillis));
      if (difference.inHours >= 24) {
        await showNotification(
          id: 101,
          title: '🔥 Don\'t lose your streak!',
          body: 'You haven\'t practiced coding in over 24 hours. Jump back in to earn XP!',
        );
      }
    }
    // Update last visit timestamp
    await prefs.setInt('last_app_visit_time', now);
  }

  /// Check for newly added courses or videos in Supabase DB
  Future<void> checkForNewContentUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCourseCount = prefs.getInt('cached_courses_count') ?? 0;
    final lastVideoCount = prefs.getInt('cached_videos_count') ?? 0;

    try {
      final coursesRes = await supabase.from('courses_db').select('id');
      final currentCourseCount = (coursesRes as List).length;

      final videosRes = await supabase.from('video_courses').select('id');
      final currentVideoCount = (videosRes as List).length;

      if (lastCourseCount > 0 && currentCourseCount > lastCourseCount) {
        final diff = currentCourseCount - lastCourseCount;
        await showNotification(
          id: 201,
          title: '🎉 New Course Added!',
          body: '$diff new interactive coding course(s) available. Check them out now!',
        );
      } else if (lastVideoCount > 0 && currentVideoCount > lastVideoCount) {
        final diff = currentVideoCount - lastVideoCount;
        await showNotification(
          id: 202,
          title: '🎬 New Video Tutorial Available!',
          body: '$diff new programming video tutorial(s) added to the hub!',
        );
      }

      await prefs.setInt('cached_courses_count', currentCourseCount);
      await prefs.setInt('cached_videos_count', currentVideoCount);
    } catch (_) {
      // Quiet fail on network issues
    }
  }
}
