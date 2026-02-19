// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasbeeh/providers/data.dart';

class NotificationsUtil {
  static const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('com.mujeeb.tasbeeh', 'Smart Tasbeeh',
          channelDescription: 'Smart Tasbeeh',
          importance: Importance.max,
          priority: Priority.max,
          ticker: 'Smart Tasbeeh');
  static const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Data? data;
  int count = 0;
  int index = 0;

  NotificationsUtil() {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(int times, Data pData) async {
    data = pData;
    count = times;
    index = 0;
    timerMethod();
  }

  Future<void> displayNotification(String message, int index) async {
    // To make text of the notification different from previous text
    for (int i = 0; i < index; i++) {
      message = message + '.';
    }
    return await flutterLocalNotificationsPlugin
        .show(0, '', message, notificationDetails, payload: '');
  }

  void timerMethod() async {
    await displayNotification(
        'Current Count: ' +
            data!.count.toString() +
            '\nTarget: ' +
            data!.targetCount.toString(),
        index);
    index++;
    if (index < count) {
      Timer(const Duration(milliseconds: 100), timerMethod);
    }
  }
}
