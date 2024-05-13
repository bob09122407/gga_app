import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('ic_launcher_background');

  void initialNotification() async {
    InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification({required String title, required String body}) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: 'drawable/ic_launcher_foreground', // This should be the correct path
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title, // Use the title parameter here
      body, // Use the body parameter here
      notificationDetails,
    );
  }
}
