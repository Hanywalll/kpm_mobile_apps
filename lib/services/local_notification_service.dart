import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static const String _channelId = 'kpm_study_reminder_channel_v1';
  static const String _channelName = 'Pengingat Belajar KPM Academy';
  static const String _channelDesc = 'Notifikasi jadwal belajar harian, simulasi ujian online, dan kelas live KPM Academy';
  static const int studyReminderBaseId = 990;

  /// Initialize local notification plugin and setup Android channel
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Can handle deep linking if needed
        },
      );

      // Create Android Notification Channel
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
        // Request runtime permission for Android 13+
        await androidPlugin.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing LocalNotificationService: $e');
    }
  }

  /// Request runtime notification permission (Android 13+ & iOS)
  static Future<bool> requestPermission() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? true;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Show an instant system tray notification immediately
  static Future<void> showInstantNotification({
    int id = 101,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF1E40AF), // Deep Blue KPM Academy
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  /// Schedule multiple daily study reminders (up to 5 times a day)
  static Future<void> scheduleMultipleDailyStudyReminders(List<TimeOfDay> times) async {
    await init();
    await cancelAllStudyReminders();

    for (int i = 0; i < times.length && i < 5; i++) {
      final time = times[i];
      final notificationId = studyReminderBaseId + i;
      
      final title = _getMotivationalTitle(time.hour);
      final body = _getMotivationalBody(time.hour);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF1E40AF),
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );

      try {
        final now = tz.TZDateTime.now(tz.local);
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await _plugin.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {
        try {
          await _plugin.show(notificationId, title, body, details);
        } catch (_) {}
      }
    }
  }

  /// Cancel all scheduled study reminders
  static Future<void> cancelAllStudyReminders() async {
    try {
      for (int i = 0; i < 10; i++) {
        await _plugin.cancel(studyReminderBaseId + i);
      }
    } catch (_) {}
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  static String _getMotivationalTitle(int hour) {
    if (hour < 11) {
      return '🌅 Semangat Belajar Pagi di KPM Academy!';
    } else if (hour < 15) {
      return '☀️ Waktu Belajar Siang: Asah Logika MNR!';
    } else if (hour < 18) {
      return '🌇 Sesi Latihan Sore: Review Materi & Soal!';
    } else {
      return '🌙 Evaluasi Belajar Malam: Sukses Bersama KPM!';
    }
  }

  static String _getMotivationalBody(int hour) {
    if (hour < 11) {
      return 'Awali hari dengan melatih penalaran Matematika Nalaria Realistik (MNR). Ayo selesaikan 5 soal hari ini!';
    } else if (hour < 15) {
      return 'Istirahat sejenak sambil diskusi bersama AI Tutor atau tonton video pembahasan materi sains favoritmu!';
    } else if (hour < 18) {
      return 'Persiapkan diri untuk simulasi ujian online dan ikuti live class interaktif bersama Master Tutor KPM!';
    } else {
      return 'Review hasil skor latihanmu hari ini dan rancang target belajar untuk besok bersama KPM Academy!';
    }
  }
}
