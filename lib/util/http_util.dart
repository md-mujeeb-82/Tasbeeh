// ignore_for_file: constant_identifier_names

import 'package:http/http.dart' as http;

import 'package:tasbeeh/providers/data.dart';

class HTTPUtil {
  static const ENDPOINT_GET_DATA = 'getData';
  static const ENDPOINT_SAVE_DATA = 'saveData';

  Data? dataProvider;

  HTTPUtil({required this.dataProvider});

  Future<Map<String, dynamic>> getData() async {
    final uri = Uri.http(dataProvider!.smartDeviceIPAddress, ENDPOINT_GET_DATA);
    final response = await http.get(uri);

    List<String> values = response.body.split(':');
    Map<String, dynamic> data = {};
    data[Data.KEY_DEVICE_COUNT] = int.parse(values[1]);
    data[Data.KEY_DEVICE_TARGET_COUNT] = int.parse(values[2]);
    data[Data.KEY_DEVICE_DAY_COUNT] = int.parse(values[3]);
    data[Data.KEY_DEVICE_TOTAL_COUNT] = int.parse(values[4]);
    data[Data.KEY_DEVICE_STEP] = int.parse(values[5]);
    data[Data.KEY_DEVICE_TICK_DURATION] = int.parse(values[6]);
    data[Data.KEY_DEVICE_MIN_TICK_DURATION] = int.parse(values[7]);
    data[Data.KEY_DEVICE_AUDIO_ON] = values[8] == 'true';
    data[Data.KEY_DEVICE_VIBRATE_ON] = values[9] == 'true';
    data[Data.KEY_DEVICE_AUTO_PILOT_ON] = values[10] == 'true';
    return data;
  }

  Future<bool> saveCount(String whichCount) async {
    String parameter = '';
    int countToBeSaved = -1;

    switch (whichCount) {
      case Data.HEADER_REQUEST_SAVE_COUNTS_1:
        parameter = 'count';
        countToBeSaved = dataProvider!.count;
        break;
      case Data.HEADER_REQUEST_SAVE_COUNTS_2:
        parameter = 'target';
        countToBeSaved = dataProvider!.targetCount;
        break;
      case Data.HEADER_REQUEST_SAVE_COUNTS_3:
        parameter = 'day';
        countToBeSaved = dataProvider!.dayCount;
        break;
      case Data.HEADER_REQUEST_SAVE_COUNTS_4:
        parameter = 'total';
        countToBeSaved = dataProvider!.totalCount;
        break;
      default:
        countToBeSaved = -1;
        break;
    }

    if (countToBeSaved == -1) {
      return false;
    }

    final uri = Uri.http(dataProvider!.smartDeviceIPAddress, ENDPOINT_SAVE_DATA,
        {parameter: countToBeSaved.toString()});
    final response = await http.get(uri);
    return response.body == '0';
  }

  Future<bool> saveConfiguration() async {
    final uri =
        Uri.http(dataProvider!.smartDeviceIPAddress, ENDPOINT_SAVE_DATA, {
      'step': dataProvider!.step.toString(),
      'tickDuration': dataProvider!.tickDuration.toString(),
      'minTickDuration': dataProvider!.minTickDuration.toString(),
      'buzzer': dataProvider!.isAudioOn ? '1' : '0',
      'vibrator': dataProvider!.isVibrateOn ? '1' : '0',
      'autoPilot': dataProvider!.isAutoPilotOn ? '1' : '0',
    });
    final response = await http.get(uri);
    return response.body == '0';
  }
}
