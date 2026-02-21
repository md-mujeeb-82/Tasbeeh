// ignore_for_file: prefer_interpolation_to_compose_strings, annotate_overrides, avoid_print, constant_identifier_names, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_bluetooth_classic_serial/flutter_bluetooth_classic.dart';

import 'package:tasbeeh/services/audio_handler.dart';
import 'package:tasbeeh/util/audio_util.dart';
import 'package:tasbeeh/util/notifications_util.dart';
import 'package:tasbeeh/util/http_util.dart';
import 'package:tasbeeh/util/provider_util.dart';
import 'package:usb_serial/usb_serial.dart';

class Data with ChangeNotifier {
  // Shared Preferences KEY constants
  static const SHARED_PREFERENCES_KEY = 'TasbeehData';
  static const KEY_COUNT = 'count';
  static const KEY_TARGET_COUNT = 'targetCount';
  static const KEY_DAY_COUNT = 'dayCount';
  static const KEY_TOTAL_COUNT = 'totalCount';
  static const KEY_STEP = 'step';
  static const KEY_TICK_DURATION = 'tickDuration';
  static const KEY_MIN_TICK_DURATION = 'minTickDuration';
  static const KEY_AUDIO_ON = 'isAudioOn';
  static const KEY_VIBRATE_ON = 'isVibrateOn';
  static const KEY_IS_SPEECH_ON = 'isSpeechOn';
  static const KEY_IS_NOTIFICATION_ON = 'isNotificationOn';
  static const KEY_IS_USING_DEVICE = 'isUsingDevice';
  static const KEY_IS_WIFI_DEVICE = 'isWiFiDevice';
  static const KEY_IS_BLUETOOTH_DEVICE = 'isBluetoothDevice';
  static const KEY_AUTO_PILOT_ON = 'isAutoPilotOn';
  static const KEY_IS_PLAY_PAUSE = 'isPlayPause';
  static const KEY_IS_DEVICE_AVAILABLE = 'isDeviceAvailable';

  // Keys for UI Refresh
  static const KEY_DIRTY_HOME_PAGE = 'isDirtyHomePage';
  static const KEY_DIRTY_COUNTS_EDIT_PAGE = 'isDirtyCountsEditPage';
  static const KEY_DIRTY_CONFIG_EDIT_PAGE = 'isDirtyConfigEditPage';
  static const KEY_DIRTY_SMART_DEVICE_PAGE = 'isDirtySmartDevicePage';

  // Keys for Smart Device temporary Data
  static const KEY_DEVICE_IP_ADDRESS = 'smartDeviceIPAddress';
  static const KEY_DEVICE_COUNT = 'deviceCount';
  static const KEY_DEVICE_TARGET_COUNT = 'deviceTargetCount';
  static const KEY_DEVICE_DAY_COUNT = 'deviceDayCount';
  static const KEY_DEVICE_TOTAL_COUNT = 'deviceTotalCount';
  static const KEY_DEVICE_STEP = 'deviceStep';
  static const KEY_DEVICE_TICK_DURATION = 'deviceTickDuration';
  static const KEY_DEVICE_MIN_TICK_DURATION = 'deviceMinTickDuration';
  static const KEY_DEVICE_AUDIO_ON = 'deviceIsAudioOn';
  static const KEY_DEVICE_VIBRATE_ON = 'deviceIsVibrateOn';
  static const KEY_DEVICE_AUTO_PILOT_ON = 'deviceIsAutoPilotOn';

  // Bluetooth Communication constants
  static const HEADER_REQUEST_DATA_COUNTS_1 = 'A';
  static const HEADER_REQUEST_DATA_COUNTS_2 = 'B';
  static const HEADER_REQUEST_DATA_COUNTS_3 = 'C';
  static const HEADER_REQUEST_DATA_COUNTS_4 = 'D';
  static const HEADER_REQUEST_DATA_CONFIG_1 = 'E';
  static const HEADER_REQUEST_DATA_CONFIG_2 = 'F';
  static const HEADER_REQUEST_DATA_CONFIG_3 = 'G';
  static const HEADER_REQUEST_SAVE_COUNTS_1 = 'H';
  static const HEADER_REQUEST_SAVE_COUNTS_2 = 'I';
  static const HEADER_REQUEST_SAVE_COUNTS_3 = 'J';
  static const HEADER_REQUEST_SAVE_COUNTS_4 = 'K';
  static const HEADER_REQUEST_SAVE_CONFIG_1 = 'L';
  static const HEADER_REQUEST_SAVE_CONFIG_2 = 'M';
  static const HEADER_REQUEST_SAVE_CONFIG_3 = 'N';

  static const HEADER_REPLY_DATA_COUNTS_1 = 'A';
  static const HEADER_REPLY_DATA_COUNTS_2 = 'B';
  static const HEADER_REPLY_DATA_COUNTS_3 = 'C';
  static const HEADER_REPLY_DATA_COUNTS_4 = 'D';
  static const HEADER_REPLY_DATA_CONFIG_1 = 'E';
  static const HEADER_REPLY_DATA_CONFIG_2 = 'F';
  static const HEADER_REPLY_DATA_CONFIG_3 = 'G';
  static const HEADER_REPLY_SAVE_COUNTS_1 = 'H';
  static const HEADER_REPLY_SAVE_COUNTS_2 = 'I';
  static const HEADER_REPLY_SAVE_COUNTS_3 = 'J';
  static const HEADER_REPLY_SAVE_COUNTS_4 = 'K';
  static const HEADER_REPLY_SAVE_CONFIG_1 = 'L';
  static const HEADER_REPLY_SAVE_CONFIG_2 = 'M';
  static const HEADER_REPLY_SAVE_CONFIG_3 = 'N';

  final dynamic _data = {};
  bool isFetchingData = false;
  AudioUtil audioUtil = AudioUtil();
  NotificationsUtil notificationUtil = NotificationsUtil();
  HTTPUtil? httpUtil;
  TasbeehAudioHandler? _audioHandler;
  BluetoothDevice? tasbeehDevice;
  FlutterBluetoothClassic ? blueTooth;
  UsbPort? usbPort;

  Data() {
    // Data Saved on Phone
    _data[KEY_COUNT] = 0;
    _data[KEY_TARGET_COUNT] = 100;
    _data[KEY_DAY_COUNT] = 0;
    _data[KEY_TOTAL_COUNT] = 0;
    _data[KEY_STEP] = 1;
    _data[KEY_TICK_DURATION] = 2000;
    _data[KEY_MIN_TICK_DURATION] = 1200;
    _data[KEY_AUDIO_ON] = true;
    _data[KEY_VIBRATE_ON] = true;
    _data[KEY_IS_SPEECH_ON] = true;
    _data[KEY_IS_NOTIFICATION_ON] = false;
    _data[KEY_IS_USING_DEVICE] = false;
    _data[KEY_IS_WIFI_DEVICE] = true;
    _data[KEY_AUTO_PILOT_ON] = false;
    _data[KEY_IS_PLAY_PAUSE] = false;

    // Temporary Device Data
    _data[KEY_DEVICE_COUNT] = -1;
    _data[KEY_DEVICE_TARGET_COUNT] = -1;
    _data[KEY_DEVICE_DAY_COUNT] = -1;
    _data[KEY_DEVICE_TOTAL_COUNT] = -1;
    _data[KEY_DEVICE_STEP] = -1;
    _data[KEY_DEVICE_TICK_DURATION] = -1;
    _data[KEY_DEVICE_MIN_TICK_DURATION] = -1;
    _data[KEY_DEVICE_AUDIO_ON] = false;
    _data[KEY_DEVICE_VIBRATE_ON] = false;
    _data[KEY_DEVICE_AUTO_PILOT_ON] = false;
    _data[KEY_DEVICE_IP_ADDRESS] = 'unknown';

    setDeviceAvailable(false);
    setDirty('', true);

    httpUtil = HTTPUtil(dataProvider: this);

    // For Audio Service
    audioUtil.loadAudio();
  }

  Future<bool> fetchAndSetData() async {
    dynamic prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      dynamic data = prefs.get(SHARED_PREFERENCES_KEY);
      if (data == null) {
        return true;
      }

      _audioHandler = (await initAudioService() as TasbeehAudioHandler);
      _audioHandler?.setData(this);

      data = json.decode(data);
      _data[KEY_COUNT] = int.parse(data[KEY_COUNT]);
      _data[KEY_TARGET_COUNT] = int.parse(data[KEY_TARGET_COUNT]);
      _data[KEY_DAY_COUNT] = int.parse(data[KEY_DAY_COUNT]);
      _data[KEY_TOTAL_COUNT] = int.parse(data[KEY_TOTAL_COUNT]);
      _data[KEY_STEP] = int.parse(data[KEY_STEP]);
      _data[KEY_TICK_DURATION] = int.parse(data[KEY_TICK_DURATION]);
      _data[KEY_MIN_TICK_DURATION] = int.parse(data[KEY_MIN_TICK_DURATION]);
      _data[KEY_AUDIO_ON] =
          data[KEY_AUDIO_ON].toString().toLowerCase() == 'true';
      _data[KEY_VIBRATE_ON] =
          data[KEY_VIBRATE_ON].toString().toLowerCase() == 'true';
      _data[KEY_IS_SPEECH_ON] =
          data[KEY_IS_SPEECH_ON].toString().toLowerCase() == 'true';
      _data[KEY_IS_NOTIFICATION_ON] =
          data[KEY_IS_NOTIFICATION_ON].toString().toLowerCase() == 'true';
      _data[KEY_IS_USING_DEVICE] =
          data[KEY_IS_USING_DEVICE].toString().toLowerCase() == 'true';
      _data[KEY_IS_WIFI_DEVICE] =
          data[KEY_IS_WIFI_DEVICE].toString().toLowerCase() == 'true';
      _data[KEY_AUTO_PILOT_ON] =
          data[KEY_AUTO_PILOT_ON].toString().toLowerCase() == 'true';
      _data[KEY_IS_PLAY_PAUSE] =
          data[KEY_IS_PLAY_PAUSE].toString().toLowerCase() == 'true';
      setDirty('', true);
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> saveData() async {
    dynamic prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          SHARED_PREFERENCES_KEY,
          json.encode({
            KEY_COUNT: count.toString(),
            KEY_TARGET_COUNT: targetCount.toString(),
            KEY_DAY_COUNT: dayCount.toString(),
            KEY_TOTAL_COUNT: totalCount.toString(),
            KEY_STEP: step.toString(),
            KEY_TICK_DURATION: tickDuration.toString(),
            KEY_MIN_TICK_DURATION: minTickDuration.toString(),
            KEY_AUDIO_ON: isAudioOn.toString(),
            KEY_VIBRATE_ON: isVibrateOn.toString(),
            KEY_IS_SPEECH_ON: isSpeechOn.toString(),
            KEY_IS_NOTIFICATION_ON: isNotificationOn.toString(),
            KEY_IS_USING_DEVICE: isUsingDevice.toString(),
            KEY_IS_WIFI_DEVICE: isWiFiDevice.toString(),
            KEY_IS_BLUETOOTH_DEVICE: isBluetoothDevice.toString(),
            KEY_AUTO_PILOT_ON: isAutoPilotOn.toString(),
            KEY_IS_PLAY_PAUSE: isPlayPause.toString()
          }));
      setDirty('', true);
      notifyListeners();

      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> saveCounts(String pCount, String pTargetCount, String pDayCount,
      String pTotalCount) async {
    _data[KEY_COUNT] = int.parse(pCount);
    _data[KEY_TARGET_COUNT] = int.parse(pTargetCount);
    _data[KEY_DAY_COUNT] = int.parse(pDayCount);
    _data[KEY_TOTAL_COUNT] = int.parse(pTotalCount);

    return await saveData();
  }

  Future<bool> saveConfigData(
      String pStep,
      String pTickDuration,
      String pMinTickDuration,
      String pIsAudioOn,
      String pIsVibrateOn,
      String pIsSpeechOn,
      String pIsNotificationOn,
      String pIsUsingDevice,
      String pIsWiFiDevice,
      String pIsBluetoothDevice,
      String pIsAutoPilotOn) async {
    _data[KEY_STEP] = int.parse(pStep);
    _data[KEY_TICK_DURATION] = int.parse(pTickDuration);
    _data[KEY_MIN_TICK_DURATION] = int.parse(pMinTickDuration);
    _data[KEY_AUDIO_ON] = pIsAudioOn.toLowerCase() == 'true';
    _data[KEY_VIBRATE_ON] = pIsVibrateOn.toLowerCase() == 'true';
    _data[KEY_IS_SPEECH_ON] = pIsSpeechOn.toLowerCase() == 'true';
    _data[KEY_IS_NOTIFICATION_ON] = pIsNotificationOn.toLowerCase() == 'true';
    _data[KEY_IS_USING_DEVICE] = pIsUsingDevice.toLowerCase() == 'true';
    _data[KEY_IS_WIFI_DEVICE] = pIsWiFiDevice.toLowerCase() == 'true';
    _data[KEY_IS_BLUETOOTH_DEVICE] = pIsBluetoothDevice.toLowerCase() == 'true';
    _data[KEY_AUTO_PILOT_ON] = pIsAutoPilotOn.toLowerCase() == 'true';

    return await saveData();
  }

  Future<bool> changePlayPauseState(bool state) async {
    _data[KEY_IS_PLAY_PAUSE] = state;
    return await saveData();
  }

  Future<void> togglePlayPause() async {
    audioHandler!.handleButtonClick(!isPlayPause);
  }

  Future<bool> endSession() async {
    _data[KEY_DAY_COUNT] = dayCount + count;
    _data[KEY_COUNT] = 0;

    return await saveData();
  }

  Future<bool> endDay() async {
    _data[KEY_DAY_COUNT] = dayCount + count;
    _data[KEY_TOTAL_COUNT] = totalCount + dayCount;
    _data[KEY_COUNT] = 0;
    _data[KEY_DAY_COUNT] = 0;

    return await saveData();
  }

  Future<bool> resetCurrentCount() async {
    _data[KEY_COUNT] = 0;

    return await saveData();
  }

  Future<void> incrementTasbeeh() async {
    if (count >= targetCount) {
      _data[KEY_IS_PLAY_PAUSE] = false;
      if (isAudioOn) {
        await audioUtil.play100CompleteAudio(isSpeechOn, false);
      }
      if (isVibrateOn) {
        await vibrate(1000, 1);
        await usbPort!.write(Uint8List.fromList([0x3E8, 1]));
      }
      if (isNotificationOn) {
        await notificationUtil.showNotification(5, this);
      }
      setDirty('', true);
      notifyListeners();
      return;
    }

    _data[KEY_COUNT] = count + step;
    await saveData();

    if (isAudioOn) {
      if (count != 0 && count == targetCount) {
        await audioUtil.playTasbeehCompleteAudio(isSpeechOn);
      } else if (count % 100 == 0) {
        await audioUtil.play100CompleteAudio(
            isSpeechOn, isAutoPilotOn && count > 30);
      } else {
        await audioUtil.playTickAudio(isSpeechOn, isAutoPilotOn && count > 30);
      }
    }

    if (isVibrateOn) {
      // In order to aoid phone going to Sleep mode.
      if (!isAudioOn) {
        audioUtil.playSilenceAudio();
      }

      if (count != 0 && count == targetCount) {
        await vibrate(1000, 1);
        await usbPort!.write(Uint8List.fromList([0x3E8, 1]));
      } else if (count % 100 == 0) {
        await vibrate(100, 3);
        await usbPort!.write(Uint8List.fromList([0x64, 3]));
      } else {
        await vibrate(100, 1);
        await usbPort!.write(Uint8List.fromList([0x64, 1]));
      }
    }

    if (isNotificationOn) {
      if (count != 0 && count == targetCount) {
        await notificationUtil.showNotification(5, this);
      } else if (count % 100 == 0) {
        await notificationUtil.showNotification(2, this);
      } else {
        await notificationUtil.showNotification(1, this);
      }
    }
  }

  Future<void> vibrate(int millis, int count) async {
    for (int i = 0; i < count; i++) {
      Vibration.vibrate(duration: millis);
      await usbPort!.write(Uint8List.fromList([millis, 1]));
    }
  }

  // Smart Device Methods

  // WiFi Device Methods
  void setSmartDeviceIPAddress(String ipAddress) {
    _data[KEY_DEVICE_IP_ADDRESS] = ipAddress;
    setDeviceAvailable(true);
    setDirty('', true);
    notifyListeners();
  }

  Future<void> fetchAndSetWiFiDeviceData() async {
    isFetchingData = true;
    Map<String, dynamic> result = await httpUtil!.getData();
    _data[KEY_DEVICE_COUNT] = result[KEY_DEVICE_COUNT];
    _data[KEY_DEVICE_TARGET_COUNT] = result[KEY_DEVICE_TARGET_COUNT];
    _data[KEY_DEVICE_DAY_COUNT] = result[KEY_DEVICE_DAY_COUNT];
    _data[KEY_DEVICE_TOTAL_COUNT] = result[KEY_DEVICE_TOTAL_COUNT];
    _data[KEY_DEVICE_STEP] = result[KEY_DEVICE_STEP];
    _data[KEY_DEVICE_TICK_DURATION] = result[KEY_DEVICE_TICK_DURATION];
    _data[KEY_DEVICE_MIN_TICK_DURATION] = result[KEY_DEVICE_MIN_TICK_DURATION];
    _data[KEY_DEVICE_AUDIO_ON] = result[KEY_DEVICE_AUDIO_ON];
    _data[KEY_DEVICE_VIBRATE_ON] = result[KEY_DEVICE_VIBRATE_ON];
    _data[KEY_DEVICE_AUTO_PILOT_ON] = result[KEY_DEVICE_AUTO_PILOT_ON];
    setDirty('', true);
    isFetchingData = false;
    notifyListeners();
  }

  Future<bool> saveCountToWiFiDevice(String whichCount) async {
    isFetchingData = true;
    bool result = await httpUtil!.saveCount(whichCount);
    if (result) {
      replaceDeviceCountsData(whichCount);
    }
    return result;
  }

  Future<bool> saveConfigurationToWiFiDevice() async {
    isFetchingData = true;
    bool result = await httpUtil!.saveConfiguration();
    if (result) {
      replaceDeviceConfigData(-1);
    }
    return result;
  }

  // Bluetooth Communication Methods

  Future<bool> requestPermissionsAndStartDiscovery() async {
    if (isUsingDevice) {
      ProviderUtil.requestBluetoothPermission().then((result) {
        if (result) {
          try {
            // Setup a list of the bonded devices
            FlutterBluetoothClassic()
                .getPairedDevices()
                .then((List<BluetoothDevice> bondedDevices) {
              // Find our Bluetooth Device and set it in our Service
              setBluetoothDevice(bondedDevices
                  .firstWhere((element) => element.name == 'Smart Tasbeeh'));
              // if (getBluetoothDevice != null) {
              //   FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
              //     // print('>>>>> Device: ' + r.device.toString());
              //     if (tasbeehDevice! == r.device) {
              //       // print('>>>>> Device Found!');
              setDeviceAvailable(true);
              //     }
              //   });
              // }
            });
            return true;
          } catch (error) {
            // Do Nothing
          }
        } else {
          return false;
        }
      });
    }

    return true;
  }

  void setBluetoothDevice(BluetoothDevice device) async {
    tasbeehDevice = device;
  }

  BluetoothDevice get getBluetoothDevice {
    return tasbeehDevice!;
  }

  void connectBluetoothDeviceAndListen() async {
    if (isDeviceConnected) {
      return;
    }
    isFetchingData = true;
    try {
      await blueTooth!.connect(tasbeehDevice!.address);
      setDirty('', true);

      blueTooth!.onDataReceived.listen((BluetoothData data) async {
        String header = String.fromCharCode(data.data.elementAt(0));

        // print('Incoming header: ' + header);

        var str = '';
        for (var i = 1; i < data.data.length; i++) {
          str = str + String.fromCharCode(data.data.elementAt(i));
        }

        // print('Incoming data: ' + str);

        if (header == HEADER_REPLY_DATA_COUNTS_1) {
          _data[KEY_DEVICE_COUNT] = int.parse(str);
          setDirty('', true);
          notifyListeners();
          requestDataFromBluetoothDevice(1);
        } else if (header == HEADER_REPLY_DATA_COUNTS_2) {
          _data[KEY_DEVICE_TARGET_COUNT] = int.parse(str);
          setDirty('', true);
          notifyListeners();
          requestDataFromBluetoothDevice(2);
        } else if (header == HEADER_REPLY_DATA_COUNTS_3) {
          _data[KEY_DEVICE_DAY_COUNT] = int.parse(str);
          setDirty('', true);
          notifyListeners();
          requestDataFromBluetoothDevice(3);
        } else if (header == HEADER_REPLY_DATA_COUNTS_4) {
          _data[KEY_DEVICE_TOTAL_COUNT] = int.parse(str);
          setDirty('', true);
          notifyListeners();
          requestDataFromBluetoothDevice(4);
        } else if (header == HEADER_REPLY_DATA_CONFIG_1) {
          _data[KEY_DEVICE_TICK_DURATION] = int.parse(str);
          setDirty('', true);
          notifyListeners();
          requestDataFromBluetoothDevice(5);
        } else if (header == HEADER_REPLY_DATA_CONFIG_2) {
          _data[KEY_DEVICE_MIN_TICK_DURATION] = int.parse(str);
          setDirty('', true);
          notifyListeners();
          requestDataFromBluetoothDevice(6);
        } else if (header == HEADER_REPLY_DATA_CONFIG_3) {
          var strData = str.split(':');
          _data[KEY_DEVICE_STEP] = int.parse(strData[0]);
          _data[KEY_DEVICE_AUDIO_ON] = strData[1] == '1';
          _data[KEY_DEVICE_VIBRATE_ON] = strData[2] == '1';
          _data[KEY_DEVICE_AUTO_PILOT_ON] = strData[3] == '1';
          setDirty('', true);
          isFetchingData = false;
          notifyListeners();
        } else if (header == HEADER_REPLY_SAVE_COUNTS_1) {
          replaceDeviceCountsData(HEADER_REQUEST_SAVE_COUNTS_1);
        } else if (header == HEADER_REPLY_SAVE_COUNTS_2) {
          replaceDeviceCountsData(HEADER_REQUEST_SAVE_COUNTS_2);
        } else if (header == HEADER_REPLY_SAVE_COUNTS_3) {
          replaceDeviceCountsData(HEADER_REQUEST_SAVE_COUNTS_3);
        } else if (header == HEADER_REPLY_SAVE_COUNTS_4) {
          replaceDeviceCountsData(HEADER_REQUEST_SAVE_COUNTS_4);
        } else if (header == HEADER_REPLY_SAVE_CONFIG_1) {
          replaceDeviceConfigData(1);
          saveConfigDataToBluetoothDevice(2);
        } else if (header == HEADER_REPLY_SAVE_CONFIG_2) {
          replaceDeviceConfigData(2);
          saveConfigDataToBluetoothDevice(3);
        } else if (header == HEADER_REPLY_SAVE_CONFIG_3) {
          replaceDeviceConfigData(3);
        }
      });
    } catch (error) {
      print(error);
    }

    requestDataFromBluetoothDevice(0);
  }

  void disconnectBluetoothDevice() async {
    try {
      // await blueTooth!.finish();
      setDirty('', true);
    } catch (error) {
      // Do Nothing
    }
  }

  Future<void> requestDataFromBluetoothDevice(int whichData) async {
    if (!isDeviceConnected) {
      connectBluetoothDeviceAndListen();
    }
    isFetchingData = true;
    String header;
    switch (whichData) {
      case 0:
        header = HEADER_REQUEST_DATA_COUNTS_1;
        break;
      case 1:
        header = HEADER_REQUEST_DATA_COUNTS_2;
        break;
      case 2:
        header = HEADER_REQUEST_DATA_COUNTS_3;
        break;
      case 3:
        header = HEADER_REQUEST_DATA_COUNTS_4;
        break;
      case 4:
        header = HEADER_REQUEST_DATA_CONFIG_1;
        break;
      case 5:
        header = HEADER_REQUEST_DATA_CONFIG_2;
        break;
      case 6:
        header = HEADER_REQUEST_DATA_CONFIG_3;
        break;
      default:
        header = HEADER_REQUEST_DATA_COUNTS_1;
        break;
    }
    Uint8List list = Uint8List.fromList(header.codeUnits);
    // print('Outgoing: ' + list.toString());
    blueTooth!.sendData(list);
  }

  Future<void> saveCountDataToBluetoothDevice(int whichCount) async {
    if (!isDeviceConnected) {
      connectBluetoothDeviceAndListen();
    }

    isFetchingData = true;
    Uint8List? list;
    switch (whichCount) {
      case 1:
        list = Uint8List.fromList(
            (HEADER_REQUEST_SAVE_COUNTS_1 + count.toString()).codeUnits);
        break;
      case 2:
        list = Uint8List.fromList(
            (HEADER_REQUEST_SAVE_COUNTS_2 + targetCount.toString()).codeUnits);
        break;
      case 3:
        list = Uint8List.fromList(
            (HEADER_REQUEST_SAVE_COUNTS_3 + dayCount.toString()).codeUnits);
        break;
      case 4:
        list = Uint8List.fromList(
            (HEADER_REQUEST_SAVE_COUNTS_4 + totalCount.toString()).codeUnits);
        break;
    }

    // print('Outgoing: ' + list.toString());
    blueTooth!.sendData(list!);
  }

  Future<void> saveConfigDataToBluetoothDevice(int whichConfig) async {
    if (!isDeviceConnected) {
      connectBluetoothDeviceAndListen();
    }

    isFetchingData = true;
    Uint8List? list;

    switch (whichConfig) {
      case 1:
        list = Uint8List.fromList(
            (HEADER_REQUEST_SAVE_CONFIG_1.toString() + tickDuration.toString())
                .codeUnits);
        break;
      case 2:
        list = Uint8List.fromList((HEADER_REQUEST_SAVE_CONFIG_2.toString() +
                minTickDuration.toString())
            .codeUnits);
        break;
      case 3:
        list = Uint8List.fromList((HEADER_REQUEST_SAVE_CONFIG_3.toString() +
                step.toString() +
                ':' +
                (isAudioOn ? '1' : '0') +
                ':' +
                (isVibrateOn ? '1' : '0') +
                ':' +
                (isAutoPilotOn ? '1' : '0'))
            .codeUnits);
        break;
    }

    // print('Outgoing: ' + list.toString());
    blueTooth!.sendData(list!);
  }

  // USB Serial Methods
  void initializeUSBDevice() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
        print(devices);

        if (devices.isEmpty) {
          return;
        }
        usbPort = await devices[0].create();

        if(usbPort != null) {
          bool openResult = await usbPort!.open();
          if ( !openResult ) {
            print("Failed to open");
            return;
          }

          await usbPort!.setDTR(true);
          await usbPort!.setRTS(true);

          usbPort!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

          // print first result and close port.
          usbPort!.inputStream!.listen((Uint8List event) {
            if(event.first == 0) {
              if(isAutoPilotOn) {
                togglePlayPause();
              } else {
                incrementTasbeeh();
              }
            }
          });
        }
  }

  // Common methods for Smart Device

  void replaceDeviceConfigData(int whichConfig) {
    switch (whichConfig) {
      case 1:
        _data[KEY_DEVICE_TICK_DURATION] = tickDuration;
        break;
      case 2:
        _data[KEY_DEVICE_MIN_TICK_DURATION] = minTickDuration;
        break;
      case 3:
        _data[KEY_DEVICE_STEP] = step;
        _data[KEY_DEVICE_AUDIO_ON] = isAudioOn;
        _data[KEY_DEVICE_VIBRATE_ON] = isVibrateOn;
        _data[KEY_DEVICE_AUTO_PILOT_ON] = isAutoPilotOn;
        break;
      case -1:
        _data[KEY_DEVICE_STEP] = step;
        _data[KEY_DEVICE_TICK_DURATION] = tickDuration;
        _data[KEY_DEVICE_MIN_TICK_DURATION] = minTickDuration;
        _data[KEY_DEVICE_AUDIO_ON] = isAudioOn;
        _data[KEY_DEVICE_VIBRATE_ON] = isVibrateOn;
        _data[KEY_DEVICE_AUTO_PILOT_ON] = isAutoPilotOn;
        break;
    }
    setDirty('', true);
    isFetchingData = false;
    notifyListeners();
  }

  void replaceDeviceCountsData(String whichCount) {
    switch (whichCount) {
      case HEADER_REQUEST_SAVE_COUNTS_1:
        _data[KEY_DEVICE_COUNT] = count;
        break;
      case HEADER_REQUEST_SAVE_COUNTS_2:
        _data[KEY_DEVICE_TARGET_COUNT] = targetCount;
        break;
      case HEADER_REQUEST_SAVE_COUNTS_3:
        _data[KEY_DEVICE_DAY_COUNT] = dayCount;
        break;
      case HEADER_REQUEST_SAVE_COUNTS_4:
        _data[KEY_DEVICE_TOTAL_COUNT] = totalCount;
        break;
    }
    setDirty('', true);
    isFetchingData = false;
    notifyListeners();
  }

  // Getter/Setter methods

  void setDirty(String whichOne, bool state) {
    if (state) {
      _data[Data.KEY_DIRTY_HOME_PAGE] = true;
      _data[Data.KEY_DIRTY_COUNTS_EDIT_PAGE] = true;
      _data[Data.KEY_DIRTY_CONFIG_EDIT_PAGE] = true;
      _data[Data.KEY_DIRTY_SMART_DEVICE_PAGE] = true;
    } else {
      switch (whichOne) {
        case KEY_DIRTY_HOME_PAGE:
          _data[Data.KEY_DIRTY_HOME_PAGE] = false;
          break;
        case KEY_DIRTY_COUNTS_EDIT_PAGE:
          _data[Data.KEY_DIRTY_COUNTS_EDIT_PAGE] = false;
          break;
        case KEY_DIRTY_CONFIG_EDIT_PAGE:
          _data[Data.KEY_DIRTY_CONFIG_EDIT_PAGE] = false;
          break;
        case KEY_DIRTY_SMART_DEVICE_PAGE:
          _data[Data.KEY_DIRTY_SMART_DEVICE_PAGE] = false;
          break;
      }
    }
  }

  void setDeviceAvailable(bool isAvailable) {
    _data[KEY_IS_DEVICE_AVAILABLE] = isAvailable;
    setDirty('', true);
    notifyListeners();
  }

  dynamic get data {
    return _data;
  }

  int get count {
    return _data[KEY_COUNT];
  }

  int get targetCount {
    return _data[KEY_TARGET_COUNT];
  }

  int get dayCount {
    return _data[KEY_DAY_COUNT];
  }

  int get totalCount {
    return _data[KEY_TOTAL_COUNT];
  }

  int get step {
    return _data[KEY_STEP];
  }

  int get tickDuration {
    return _data[KEY_TICK_DURATION];
  }

  int get minTickDuration {
    return _data[KEY_MIN_TICK_DURATION];
  }

  bool get isAudioOn {
    return _data[KEY_AUDIO_ON];
  }

  bool get isVibrateOn {
    return _data[KEY_VIBRATE_ON];
  }

  bool get isNotificationOn {
    return _data[KEY_IS_NOTIFICATION_ON];
  }

  bool get isUsingDevice {
    return _data[KEY_IS_USING_DEVICE];
  }

  bool get isWiFiDevice {
    return _data[KEY_IS_WIFI_DEVICE];
  }

  bool get isBluetoothDevice {
    return _data[KEY_IS_BLUETOOTH_DEVICE];
  }

  bool get isSpeechOn {
    return _data[KEY_IS_SPEECH_ON];
  }

  bool get isAutoPilotOn {
    return _data[KEY_AUTO_PILOT_ON];
  }

  get deviceCount {
    return _data[KEY_DEVICE_COUNT];
  }

  get deviceTargetCount {
    return _data[KEY_DEVICE_TARGET_COUNT];
  }

  get deviceDayCount {
    return _data[KEY_DEVICE_DAY_COUNT];
  }

  get deviceTotalCount {
    return _data[KEY_DEVICE_TOTAL_COUNT];
  }

  int get deviceStep {
    return _data[KEY_DEVICE_STEP];
  }

  int get deviceTickDuration {
    return _data[KEY_DEVICE_TICK_DURATION];
  }

  int get deviceMinTickDuration {
    return _data[KEY_DEVICE_MIN_TICK_DURATION];
  }

  bool get deviceIsAudioOn {
    return _data[KEY_DEVICE_AUDIO_ON];
  }

  bool get deviceIsVibrateOn {
    return _data[KEY_DEVICE_VIBRATE_ON];
  }

  bool get deviceIsAutoPilotOn {
    return _data[KEY_DEVICE_AUTO_PILOT_ON];
  }

  bool get isPlayPause {
    return _data[KEY_IS_PLAY_PAUSE];
  }

  String get smartDeviceIPAddress {
    return _data[KEY_DEVICE_IP_ADDRESS];
  }

  TasbeehAudioHandler? get audioHandler {
    return _audioHandler;
  }

  bool get isDeviceConnected {
    if (blueTooth != null) {
      return true;
    } else {
      return false;
    }
  }

  bool get isDeviceAvailable {
    return _data[KEY_IS_DEVICE_AVAILABLE];
  }

  bool isDirty(String whichOne) {
    switch (whichOne) {
      case KEY_DIRTY_HOME_PAGE:
        return _data[Data.KEY_DIRTY_HOME_PAGE];
      case KEY_DIRTY_COUNTS_EDIT_PAGE:
        return _data[Data.KEY_DIRTY_COUNTS_EDIT_PAGE];
      case KEY_DIRTY_CONFIG_EDIT_PAGE:
        return _data[Data.KEY_DIRTY_CONFIG_EDIT_PAGE];
      case KEY_DIRTY_SMART_DEVICE_PAGE:
        return _data[Data.KEY_DIRTY_SMART_DEVICE_PAGE];
      default:
        return false;
    }
  }
}
