// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:tasbeeh/providers/data.dart';

class ProviderUtil {
  static Future<bool> loadAllProviders(BuildContext context) async {
    final data = Provider.of<Data>(context, listen: false);

    await requestPhonePermission();
    await data.fetchAndSetData();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    return true;
  }

  static Future<bool> requestPhonePermission() async {
    return await Permission.phone.request() == PermissionStatus.granted;
  }

  static Future<bool> requestBluetoothPermission() async {
    var status1 = await Permission.bluetoothScan.request();
    var status2 = await Permission.bluetoothConnect.request();
    var status3 = await Permission.locationWhenInUse.request();

    if (status1 == PermissionStatus.granted &&
        status2 == PermissionStatus.granted &&
        (status3 == PermissionStatus.granted ||
            status3 == PermissionStatus.limited ||
            status3 == PermissionStatus.restricted)) {
      return true;
    } else {
      return false;
    }
  }
}
