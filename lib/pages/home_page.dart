// ignore_for_file: use_key_in_widget_constructors, constant_identifier_names, library_private_types_in_public_api, use_build_context_synchronously, import_of_legacy_library_into_null_safe, sized_box_for_whitespace

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nsd/nsd.dart';

import 'package:tasbeeh/providers/data.dart';
import 'package:tasbeeh/widgets/app_drawer.dart';
import 'package:tasbeeh/widgets/custom_alert_dialog.dart';
import 'package:tasbeeh/util/function_util.dart';
import 'package:tasbeeh/util/lifecycle_util.dart';

class HomePage extends StatefulWidget {
  static const ROUTE_NAME = '/home-page';

  @override
  _HomePageState createState() => _HomePageState();

  static Future<dynamic> onMessage(Map<String, dynamic> data) async {
    return true;
  }
}

class _HomePageState extends State<HomePage> {
  final bool _isLoading = false;
  Timer? timer;
  Discovery? discovery;

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

    // Periodic UI Refresh Timer
    timer = Timer.periodic(const Duration(milliseconds: 50), checkAndRefreshUI);

    final data = Provider.of<Data>(context, listen: false);

    if (data.isUsingDevice) {
      // For WiFi Smart Device
      if (data.isWiFiDevice) {
        startDiscovery('_http._tcp').then((discovery) {
          this.discovery = discovery;
          discovery.addServiceListener((service, status) {
            if (status == ServiceStatus.found) {
              // print('Found Service: ' + service.toString());
              // print('Name: ' + service.name!);
              // print('Host: ' + service.host!);
              // print('Port: ' + service.port.toString());
              if (service.name == 'tasbeeh' && service.port == 80) {
                Provider.of<Data>(context, listen: false)
                    .setSmartDeviceIPAddress(service.host!);
              }
            }
          });
        });
      } else if(data.isBluetoothDevice) {
        // For Bluetooth Smart Device
        data.requestPermissionsAndStartDiscovery().then((result) {
          if (!result) {
            showDialog(
              context: context,
              builder: (ctx) => const CustomAlertDialog(
                'Permissions Required!',
                'These Permissions are required to Communicate with Smart Device!\nDo you want to Grant these Permissions?',
              ),
            ).then((result) async {
              if (result) {
                data.requestPermissionsAndStartDiscovery().then((result) {
                  if (!result) {
                    exit(0);
                  }
                });
              } else {
                exit(0);
              }
            });
          }
        });
      } else {  // USB Device
        data.initializeUSBDevice();
      }
    }
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
    if (data.isDirty(Data.KEY_DIRTY_HOME_PAGE)) {
      data.setDirty(Data.KEY_DIRTY_HOME_PAGE, false);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Data data = Provider.of<Data>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Smart Tasbeeh',
          style: TextStyle(
              fontSize: MediaQuery.of(context).textScaler.scale(Platform.isAndroid
                      ? (MediaQuery.of(context).size.width >= 380 ? 19 : 15)
                      : 15)),
        ),
      ),
      drawer: Drawer(
        child: MainDrawer(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 135,
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(15),
                  width: double.infinity,
                  child: Column(children: [
                    Chip(
                      label: Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height / 6,
                        width: MediaQuery.of(context).size.width / 1.1,
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Text(
                          data.count.toString(),
                          style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).textScaler.scale(100)),
                        ),
                      ),
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 100),
                    Card(
                      elevation: 6,
                      child: Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height / 7.5,
                        width: MediaQuery.of(context).size.width / 1.1,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  // data.totalCount.toString(),
                                  data.totalCount.toString(),
                                  style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).textScaler.scale(30)),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        80),
                                Text('Total',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  // data.dayCount.toString(),
                                  data.dayCount.toString(),
                                  style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).textScaler.scale(30)),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        80),
                                Text('Today',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  // data.targetCount.toString(),
                                  data.targetCount.toString(),
                                  style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).textScaler.scale(30)),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        80),
                                Text('Target',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).textScaler.scale(16),
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 100),
                    Card(
                      elevation: 6,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2.4,
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
                                    'Are you sure that you want to Reset the Current Count?',
                                  ),
                                ).then((result) async {
                                  if (result) {
                                    bool result =
                                        await data.resetCurrentCount();
                                    if (result) {
                                      setState(() {});
                                      FunctionUtil.showSnackBar(
                                          context,
                                          'Current Count was Reset Successfully!',
                                          Colors.green);
                                    } else {
                                      FunctionUtil.showErrorSnackBar(context);
                                    }
                                  }
                                });
                              },
                              icon: const Icon(Icons.reset_tv),
                              label: Text(
                                'Reset',
                                style: TextStyle(
                                    fontSize: MediaQuery.of(context).textScaler.scale(10)),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => const CustomAlertDialog(
                                        'Confirm Operation',
                                        'Are you sure that you want to End the Current Day?',
                                      ),
                                    ).then((result) async {
                                      if (result) {
                                        bool result = await data.endDay();
                                        if (result) {
                                          setState(() {});
                                          FunctionUtil.showSnackBar(
                                              context,
                                              'Today Ended Successfully!',
                                              Colors.green);
                                        } else {
                                          FunctionUtil.showErrorSnackBar(
                                              context);
                                        }
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.edit_attributes),
                                  label: Text(
                                    'End Day',
                                    style: TextStyle(
                                        fontSize:MediaQuery.of(context).textScaler.scale(10)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => const CustomAlertDialog(
                                        'Confirm Operation',
                                        'Are you sure that you want to End the Current Session?',
                                      ),
                                    ).then((result) async {
                                      if (result) {
                                        bool result = await data.endSession();
                                        if (result) {
                                          setState(() {});
                                          FunctionUtil.showSnackBar(
                                              context,
                                              'Session Ended Successfully!',
                                              Colors.green);
                                        } else {
                                          FunctionUtil.showErrorSnackBar(
                                              context);
                                        }
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.edit_note_outlined),
                                  label: Text(
                                    'End Session',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).textScaler.scale(10)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 20),
                            if (data.isAutoPilotOn)
                              ElevatedButton.icon(
                                onPressed: () {
                                  data.togglePlayPause();
                                  setState(() {});
                                },
                                icon: Icon(
                                    data.isPlayPause
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                    size: 100),
                                label: Text(
                                  data.isPlayPause
                                      ? 'Stop Auto Tasbeeh'
                                      : 'Start Auto Tasbeeh',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).textScaler.scale(35)),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: data.isPlayPause
                                        ? Colors.amber[700]
                                        : Colors.blue[800]),
                              ),
                            if (!data.isAutoPilotOn)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await data.incrementTasbeeh();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add, size: 100),
                                label: Text(
                                  'Tick',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).textScaler.scale(80)),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[800]),
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
