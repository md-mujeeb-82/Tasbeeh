// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, constant_identifier_names, sized_box_for_whitespace, use_build_context_synchronously

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasbeeh/providers/data.dart';
import 'package:tasbeeh/widgets/app_drawer.dart';
import 'package:tasbeeh/widgets/custom_alert_dialog.dart';
import 'package:tasbeeh/util/function_util.dart';
import 'package:tasbeeh/util/lifecycle_util.dart';

class SmartDevicePage extends StatefulWidget {
  static const ROUTE_NAME = '/smart-device-page';

  @override
  _SmartDevicePageState createState() => _SmartDevicePageState();

  static Future<dynamic> onMessage(Map<String, dynamic> data) async {
    return true;
  }
}

class _SmartDevicePageState extends State<SmartDevicePage> {
  Timer? timer;
  bool _isError = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        resumeCallBack: () async => setState(() {
              timer = Timer.periodic(
                  const Duration(milliseconds: 50), checkAndRefreshUI);
            }),
        suspendingCallBack: () async => setState(() {
              if (timer != null) {
                timer!.cancel();
              }
            })));

    final data = Provider.of<Data>(context, listen: false);
    if (data.isDeviceAvailable) {
      try {
        if (data.isWiFiDevice) {
          data.fetchAndSetWiFiDeviceData().then((value) {
            setState(() {});
          });
        } else {
          data.connectBluetoothDeviceAndListen();
        }
      } catch (error) {
        setState(() {
          _isError = true;
        });
      }
    } else {
      setState(() {
        _isError = true;
      });
    }

    timer = Timer.periodic(const Duration(milliseconds: 50), checkAndRefreshUI);
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  void checkAndRefreshUI(timer) {
    final Data data = Provider.of<Data>(context, listen: false);
    if (data.isDirty(Data.KEY_DIRTY_SMART_DEVICE_PAGE)) {
      data.setDirty(Data.KEY_DIRTY_SMART_DEVICE_PAGE, false);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Data data = Provider.of<Data>(context);
    // const dummyValue = '88888';
    const countFontSize = 25;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Smart Device',
          style: TextStyle(
              fontSize: MediaQuery.of(context).textScaler.scale(Platform.isAndroid
                      ? (MediaQuery.of(context).size.width >= 380 ? 19 : 15)
                      : 15)),
        ),
        actions: [
          if (data.isUsingDevice && data.isWiFiDevice)
            ElevatedButton.icon(
              onPressed: () {
                try {
                  Provider.of<Data>(context, listen: false)
                      .fetchAndSetWiFiDeviceData()
                      .then((value) {
                    setState(() {});
                  });
                } catch (error) {
                  setState(() {
                    _isError = true;
                  });
                }
              },
              style: ButtonStyle(
                  elevation: WidgetStateProperty.all<double>(0),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.green)),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          if (data.isUsingDevice && !data.isWiFiDevice)
            ElevatedButton.icon(
              onPressed: () {
                if (!data.isDeviceConnected) {
                  data.connectBluetoothDeviceAndListen();
                } else {
                  data.disconnectBluetoothDevice();
                }
                setState(() {});
              },
              style: ButtonStyle(
                  elevation: WidgetStateProperty.all<double>(0),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.green)),
              icon: data.isDeviceConnected
                  ? const Icon(Icons.bluetooth_connected)
                  : const Icon(Icons.bluetooth),
              label: const Text(''),
            ),
          if (data.isUsingDevice && !data.isWiFiDevice)
            ElevatedButton.icon(
              onPressed: () {
                if (!data.isDeviceConnected) {
                  data.connectBluetoothDeviceAndListen();
                } else {
                  data.requestDataFromBluetoothDevice(0);
                }
                setState(() {});
              },
              style: ButtonStyle(
                  elevation: WidgetStateProperty.all<double>(0),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.green)),
              icon: const Icon(Icons.refresh),
              label: const Text(''),
            ),
        ],
      ),
      drawer: Drawer(
        child: MainDrawer(),
      ),
      body: data.isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? const Text('Unable to Connect to Smart Device.',
                  style: TextStyle(color: Colors.red))
              : SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 135,
                    child: Container(
                      height: 100,
                      margin: const EdgeInsets.all(15),
                      width: double.infinity,
                      child: Column(children: [
                        Card(
                          elevation: 6,
                          child: Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height / 3.5,
                            width: MediaQuery.of(context).size.width / 1.1,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Smart Device Data',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).textScaler.scale(20)),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              30),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // dummyValue,
                                            data.deviceTotalCount.toString(),
                                            style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).textScaler.scale(countFontSize.toDouble())),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Text('Total',
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const CustomAlertDialog(
                                                  'Confirm Operation',
                                                  'Are you sure that you want to Save Total Count value to this Phone?',
                                                ),
                                              ).then((result) async {
                                                if (result) {
                                                  bool result =
                                                      await data.saveCounts(
                                                          data.count.toString(),
                                                          data.targetCount
                                                              .toString(),
                                                          data.dayCount
                                                              .toString(),
                                                          data.deviceTotalCount
                                                              .toString());
                                                  if (result) {
                                                    setState(() {});
                                                    FunctionUtil.showSnackBar(
                                                        context,
                                                        'Total Count was saved to this Phone Successfully!',
                                                        Colors.green);
                                                  } else {
                                                    FunctionUtil
                                                        .showErrorSnackBar(
                                                            context);
                                                  }
                                                }
                                              });
                                            },
                                            icon:
                                                const Icon(Icons.phone_android),
                                            label: const Text(''),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // dummyValue,
                                            data.deviceDayCount.toString(),
                                            style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).textScaler.scale(countFontSize.toDouble())),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Text('Today',
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const CustomAlertDialog(
                                                  'Confirm Operation',
                                                  'Are you sure that you want to Save Today\'s Count value to this Phone?',
                                                ),
                                              ).then((result) async {
                                                if (result) {
                                                  bool result =
                                                      await data.saveCounts(
                                                          data.count.toString(),
                                                          data.targetCount
                                                              .toString(),
                                                          data.deviceDayCount
                                                              .toString(),
                                                          data.totalCount
                                                              .toString());
                                                  if (result) {
                                                    setState(() {});
                                                    FunctionUtil.showSnackBar(
                                                        context,
                                                        'Today\'s Count was saved to this Phone Successfully!',
                                                        Colors.green);
                                                  } else {
                                                    FunctionUtil
                                                        .showErrorSnackBar(
                                                            context);
                                                  }
                                                }
                                              });
                                            },
                                            icon:
                                                const Icon(Icons.phone_android),
                                            label: const Text(''),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // dummyValue,
                                            data.deviceTargetCount.toString(),
                                            style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).textScaler.scale(countFontSize.toDouble())),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Text('Target',
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const CustomAlertDialog(
                                                  'Confirm Operation',
                                                  'Are you sure that you want to Save Target Count value to this Phone?',
                                                ),
                                              ).then((result) async {
                                                if (result) {
                                                  bool result =
                                                      await data.saveCounts(
                                                          data.count.toString(),
                                                          data.deviceTargetCount
                                                              .toString(),
                                                          data.dayCount
                                                              .toString(),
                                                          data.totalCount
                                                              .toString());
                                                  if (result) {
                                                    setState(() {});
                                                    FunctionUtil.showSnackBar(
                                                        context,
                                                        'Target Count was saved to this Phone Successfully!',
                                                        Colors.green);
                                                  } else {
                                                    FunctionUtil
                                                        .showErrorSnackBar(
                                                            context);
                                                  }
                                                }
                                              });
                                            },
                                            icon:
                                                const Icon(Icons.phone_android),
                                            label: const Text(''),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // dummyValue,
                                            data.deviceCount.toString(),
                                            style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).textScaler.scale(countFontSize.toDouble())),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Text('Current',
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const CustomAlertDialog(
                                                  'Confirm Operation',
                                                  'Are you sure that you want to Save Current Count value to this Phone?',
                                                ),
                                              ).then((result) async {
                                                if (result) {
                                                  bool result =
                                                      await data.saveCounts(
                                                          data.deviceCount
                                                              .toString(),
                                                          data.targetCount
                                                              .toString(),
                                                          data.dayCount
                                                              .toString(),
                                                          data.totalCount
                                                              .toString());
                                                  if (result) {
                                                    setState(() {});
                                                    FunctionUtil.showSnackBar(
                                                        context,
                                                        'Current Count was saved to this Phone Successfully!',
                                                        Colors.green);
                                                  } else {
                                                    FunctionUtil
                                                        .showErrorSnackBar(
                                                            context);
                                                  }
                                                }
                                              });
                                            },
                                            icon:
                                                const Icon(Icons.phone_android),
                                            label: const Text(''),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              140),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Step:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.deviceStep.toString(),
                                          // '88',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                100),
                                        Text(
                                          'Step Duration:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.deviceTickDuration.toString(),
                                          // '50000',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                100),
                                        Text(
                                          'Min Step Duration:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.deviceMinTickDuration.toString(),
                                          // '50000',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                      ]),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              140),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Audio:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.deviceIsAudioOn ? 'ON' : 'OFF',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                100),
                                        Text(
                                          'Vibration:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.deviceIsVibrateOn ? 'ON' : 'OFF',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                100),
                                        Text(
                                          'Auto Pilot:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.deviceIsAutoPilotOn
                                              ? 'ON'
                                              : 'OFF',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                      ]),
                                ]),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 100),
                        Card(
                          elevation: 6,
                          child: Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height / 3.5,
                            width: MediaQuery.of(context).size.width / 1.1,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Phone Data',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).textScaler.scale(20)),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              30),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // dummyValue,
                                            data.totalCount.toString(),
                                            style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).textScaler.scale(countFontSize.toDouble())),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Text('Total',
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const CustomAlertDialog(
                                                  'Confirm Operation',
                                                  'Are you sure that you want to Save Total Count value to Smart Device?',
                                                ),
                                              ).then((result) async {
                                                if (result) {
                                                  if (data.isWiFiDevice) {
                                                    result = await data
                                                        .saveCountToWiFiDevice(Data
                                                            .HEADER_REQUEST_SAVE_COUNTS_4);
                                                  } else {
                                                    await data
                                                        .saveCountDataToBluetoothDevice(
                                                            4);
                                                    result = true;
                                                  }

                                                  setState(() {});
                                                  if (result) {
                                                    FunctionUtil.showSnackBar(
                                                        context,
                                                        'Total Count was saved to Smart Device Successfully!',
                                                        Colors.green);
                                                  } else {
                                                    FunctionUtil
                                                        .showErrorSnackBar(
                                                            context);
                                                  }
                                                }
                                              });
                                            },
                                            icon: const Icon(Icons.bluetooth),
                                            label: const Text(''),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // dummyValue,
                                            data.dayCount.toString(),
                                            style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).textScaler.scale(countFontSize.toDouble())),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Text('Today',
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const CustomAlertDialog(
                                                  'Confirm Operation',
                                                  'Are you sure that you want to Save Today\'s Count value to Smart Device?',
                                                ),
                                              ).then((result) async {
                                                if (result) {
                                                  if (data.isWiFiDevice) {
                                                    result = await data
                                                        .saveCountToWiFiDevice(Data
                                                            .HEADER_REQUEST_SAVE_COUNTS_3);
                                                  } else {
                                                    await data
                                                        .saveCountDataToBluetoothDevice(
                                                            3);
                                                    result = true;
                                                  }

                                                  setState(() {});
                                                  if (result) {
                                                    FunctionUtil.showSnackBar(
                                                        context,
                                                        'Today\'s Count was saved to Smart Device Successfully!',
                                                        Colors.green);
                                                  } else {
                                                    FunctionUtil
                                                        .showErrorSnackBar(
                                                            context);
                                                  }
                                                }
                                              });
                                            },
                                            icon: const Icon(Icons.bluetooth),
                                            label: const Text(''),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // dummyValue,
                                            data.targetCount.toString(),
                                            style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).textScaler.scale(countFontSize.toDouble())),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Text('Target',
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const CustomAlertDialog(
                                                  'Confirm Operation',
                                                  'Are you sure that you want to Save Target Count value to Smart Device?',
                                                ),
                                              ).then((result) async {
                                                if (result) {
                                                  if (data.isWiFiDevice) {
                                                    result = await data
                                                        .saveCountToWiFiDevice(Data
                                                            .HEADER_REQUEST_SAVE_COUNTS_2);
                                                  } else {
                                                    await data
                                                        .saveCountDataToBluetoothDevice(
                                                            2);
                                                    result = true;
                                                  }

                                                  setState(() {});
                                                  if (result) {
                                                    FunctionUtil.showSnackBar(
                                                        context,
                                                        'Target Count was saved to Smart Device Successfully!',
                                                        Colors.green);
                                                  } else {
                                                    FunctionUtil
                                                        .showErrorSnackBar(
                                                            context);
                                                  }
                                                }
                                              });
                                            },
                                            icon: const Icon(Icons.bluetooth),
                                            label: const Text(''),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // dummyValue,
                                            data.count.toString(),
                                            style: TextStyle(
                                                color: Colors.green[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context).textScaler.scale(countFontSize.toDouble())),
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          Text('Current',
                                              style: TextStyle(
                                                  fontSize: MediaQuery.of(context).textScaler.scale(16),
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  80),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) =>
                                                    const CustomAlertDialog(
                                                  'Confirm Operation',
                                                  'Are you sure that you want to Save Current Count value to Smart Device?',
                                                ),
                                              ).then((result) async {
                                                if (result) {
                                                  if (data.isWiFiDevice) {
                                                    result = await data
                                                        .saveCountToWiFiDevice(Data
                                                            .HEADER_REQUEST_SAVE_COUNTS_1);
                                                  } else {
                                                    await data
                                                        .saveCountDataToBluetoothDevice(
                                                            1);
                                                    result = true;
                                                  }

                                                  setState(() {});
                                                  if (result) {
                                                    FunctionUtil.showSnackBar(
                                                        context,
                                                        'Current Count was saved to Smart Device Successfully!',
                                                        Colors.green);
                                                  } else {
                                                    FunctionUtil
                                                        .showErrorSnackBar(
                                                            context);
                                                  }
                                                }
                                              });
                                            },
                                            icon: const Icon(Icons.bluetooth),
                                            label: const Text(''),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blueGrey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              140),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Step:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.step.toString(),
                                          // '88',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                100),
                                        Text(
                                          'Step Duration:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.tickDuration.toString(),
                                          // '50000',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                100),
                                        Text(
                                          'Min Step Duration:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.minTickDuration.toString(),
                                          // '50000',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                      ]),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              140),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Audio:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.isAudioOn ? 'ON' : 'OFF',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                100),
                                        Text(
                                          'Vibration:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.isVibrateOn ? 'ON' : 'OFF',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                100),
                                        Text(
                                          'Auto Pilot:',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                        Text(
                                          data.isAutoPilotOn ? 'ON' : 'OFF',
                                          style: TextStyle(
                                              color: Colors.green[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context).textScaler.scale(countFontSize - 13)),
                                        ),
                                      ]),
                                ]),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 80),
                        Card(
                          elevation: 6,
                          child: Container(
                            height: MediaQuery.of(context).size.height / 6,
                            width: MediaQuery.of(context).size.width / 1.1,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => const CustomAlertDialog(
                                        'Confirm Operation',
                                        'Are you sure that you want to Save Configuration to Smart Device?',
                                      ),
                                    ).then((result) async {
                                      if (result) {
                                        if (data.isWiFiDevice) {
                                          result = await data
                                              .saveConfigurationToWiFiDevice();
                                        } else {
                                          await data
                                              .saveConfigDataToBluetoothDevice(
                                                  1);
                                          result = true;
                                        }

                                        setState(() {});
                                        if (result) {
                                          FunctionUtil.showSnackBar(
                                              context,
                                              'Configuration was saved to Smart Device Successfully!',
                                              Colors.green);
                                        } else {
                                          FunctionUtil.showErrorSnackBar(
                                              context);
                                        }
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.save, size: 50),
                                  label: Text(
                                    'Save Config',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).textScaler.scale(20)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: data.isPlayPause
                                          ? Colors.amber[700]
                                          : Colors.blue[800]),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        60),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.exit_to_app),
                                  label: Text(
                                    ' Close ',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).textScaler.scale(10)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
    );
  }
}
