import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/itinerary_item.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones(); // 타임존 초기화 추가

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleItineraryNotification(ItineraryItem item) async {
    if (!item.isAlarmEnabled) return;

    // Schedule notification 15 minutes before the start time
    final scheduledTime = item.startTime.subtract(const Duration(minutes: 15));

    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      item.id.hashCode,
      'Time to go to ${item.place.name}',
      'Your next destination starts in 15 minutes',
      _scheduleNotification(scheduledTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trip_channel',
          'Trip Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 추가
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, // 추가된 부분
      //androidAllowWhileIdle: true,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 제거
    );
  }

  Future<void> cancelItineraryNotification(ItineraryItem item) async {
    await _notificationsPlugin.cancel(item.id.hashCode);
  }

  // Helper method to convert DateTime to TZDateTime

  tz.TZDateTime _scheduleNotification(DateTime scheduledTime) {
    final now = DateTime.now();
    final scheduledDate = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    //return TZDateTime.from(scheduledDate, local);
    return tz.TZDateTime.from(scheduledTime, tz.local); // 수정됨
  }
}

