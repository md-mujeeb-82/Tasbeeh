// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, constant_identifier_names, sized_box_for_whitespace

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nsd/nsd.dart';

import 'package:tasbeeh/providers/data.dart';
import 'package:tasbeeh/util/function_util.dart';
import 'package:tasbeeh/util/lifecycle_util.dart';
import 'package:tasbeeh/widgets/custom_alert_dialog.dart';

class ConfigEditPage extends StatefulWidget {
  static const ROUTE_NAME = '/config-edit-page';

  @override
  _ConfigEditPageState createState() => _ConfigEditPageState();
}

class _ConfigEditPageState extends State<ConfigEditPage> {
  final _form = GlobalKey<FormState>();

  static const List<String> deviceTypeList = <String>[
    'WiFi',
    'Bluetooth',
    'USB'
  ];
  String dropdownValue = deviceTypeList.first;

  String? _step;
  String? _tickDuration;
  String? _minTickDuration;
  bool _isLoading = false;
  bool _isAudioActive = true;
  bool _isVibrateActive = true;
  bool _isSpeechActive = true;
  bool _isNotificationActive = true;
  bool _isUsingDevice = true;
  bool _isWiFiDevice = true;
  bool _isBluetoothDevice = true;
  bool _isAutoPilotActive = false;
  Timer? timer;

  final TextEditingController _stepController = TextEditingController();
  final TextEditingController _tickDurationController = TextEditingController();
  final TextEditingController _minTickDurationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Data data = Provider.of<Data>(context, listen: false);
    _stepController.text = data.step.toString();
    _tickDurationController.text = data.tickDuration.toString();
    _minTickDurationController.text = data.minTickDuration.toString();
    _isAudioActive = data.isAudioOn;
    _isVibrateActive = data.isVibrateOn;
    _isSpeechActive = data.isSpeechOn;
    _isNotificationActive = data.isNotificationOn;
    _isUsingDevice = data.isUsingDevice;
    _isWiFiDevice = data.isWiFiDevice;
    _isBluetoothDevice = data.isBluetoothDevice;
    _isAutoPilotActive = data.isAutoPilotOn;

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
    if (data.isDirty(Data.KEY_DIRTY_CONFIG_EDIT_PAGE)) {
      data.setDirty(Data.KEY_DIRTY_CONFIG_EDIT_PAGE, false);
      setState(() {});
    }
  }

  Future<void> _validateAndSubmitForm(context) async {
    if (_form.currentState?.validate() == true) {
      _form.currentState?.save();
      setState(() {
        _isLoading = true;
      });
      final data = Provider.of<Data>(context, listen: false);
      bool result = await data.saveConfigData(
          _step.toString(),
          _tickDuration.toString(),
          _minTickDuration.toString(),
          _isAudioActive.toString(),
          _isVibrateActive.toString(),
          _isSpeechActive.toString(),
          _isNotificationActive.toString(),
          _isUsingDevice.toString(),
          _isWiFiDevice.toString(),
          _isBluetoothDevice.toString(),
          _isAutoPilotActive.toString());
      if (result) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('Saved the Counts Successfully!'),
        // ));
        FunctionUtil.showSnackBar(
            context, 'Saved the Configuration Successfully!', Colors.black);
        if (data.isUsingDevice) {
          if (data.isWiFiDevice) {
            startDiscovery('_http._tcp').then((discovery) {
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
          } else if (data.isBluetoothDevice) {
            result = await data.requestPermissionsAndStartDiscovery();
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
                      context.exit(0);
                    }
                  });
                } else {
                  context.exit(0);
                }
              });
            }
          } else {
            // USB Device
            data.initializeUSBDevice();
          }
        }
        Navigator.of(context).pop();
      } else {
        FunctionUtil.showErrorSnackBar(context);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            color: Colors.grey,
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Form(
                    key: _form,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _stepController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Single Step',
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 80)),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter value for Current Count!';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => _step = value,
                        ),
                        TextFormField(
                          controller: _tickDurationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Auto Tick Duration (Millis)',
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 80)),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter value for Auto Tick Duration!';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => _tickDuration = value,
                        ),
                        TextFormField(
                          controller: _minTickDurationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Min Auto Tick Duration (Millis)',
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 80)),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter value for Min Auto Tick Duration!';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => _minTickDuration = value,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 22),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Audio Alert',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(16),
                                      fontWeight: FontWeight.bold)),
                              Transform.scale(
                                  scale: 2,
                                  child: Switch(
                                    onChanged: (value) {
                                      _isAudioActive = !_isAudioActive;
                                      setState(() {});
                                    },
                                    value: _isAudioActive,
                                    activeThumbColor: Colors.green[400],
                                    activeTrackColor: Colors.blueGrey,
                                    inactiveThumbColor: Colors.blueGrey[300],
                                    inactiveTrackColor: Colors.blueGrey,
                                  )),
                            ]),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 100),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Vibration Alert',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(16),
                                      fontWeight: FontWeight.bold)),
                              Transform.scale(
                                  scale: 2,
                                  child: Switch(
                                    onChanged: (value) {
                                      _isVibrateActive = !_isVibrateActive;
                                      setState(() {});
                                    },
                                    value: _isVibrateActive,
                                    activeThumbColor: Colors.green[400],
                                    activeTrackColor: Colors.blueGrey,
                                    inactiveThumbColor: Colors.blueGrey[300],
                                    inactiveTrackColor: Colors.blueGrey,
                                  )),
                            ]),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 100),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Auto Pilot',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(16),
                                      fontWeight: FontWeight.bold)),
                              Transform.scale(
                                  scale: 2,
                                  child: Switch(
                                    onChanged: (value) {
                                      _isAutoPilotActive = !_isAutoPilotActive;
                                      setState(() {});
                                    },
                                    value: _isAutoPilotActive,
                                    activeThumbColor: Colors.green[400],
                                    activeTrackColor: Colors.blueGrey,
                                    inactiveThumbColor: Colors.blueGrey[300],
                                    inactiveTrackColor: Colors.blueGrey,
                                  )),
                            ]),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 100),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Notifications',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(16),
                                      fontWeight: FontWeight.bold)),
                              Transform.scale(
                                  scale: 2,
                                  child: Switch(
                                    onChanged: (value) {
                                      _isNotificationActive =
                                          !_isNotificationActive;
                                      setState(() {});
                                    },
                                    value: _isNotificationActive,
                                    activeThumbColor: Colors.green[400],
                                    activeTrackColor: Colors.blueGrey,
                                    inactiveThumbColor: Colors.blueGrey[300],
                                    inactiveTrackColor: Colors.blueGrey,
                                  )),
                            ]),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 100),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Speech Alert',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(16),
                                      fontWeight: FontWeight.bold)),
                              Transform.scale(
                                  scale: 2,
                                  child: Switch(
                                    onChanged: (value) {
                                      _isSpeechActive = !_isSpeechActive;
                                      setState(() {});
                                    },
                                    value: _isSpeechActive,
                                    activeThumbColor: Colors.green[400],
                                    activeTrackColor: Colors.blueGrey,
                                    inactiveThumbColor: Colors.blueGrey[300],
                                    inactiveTrackColor: Colors.blueGrey,
                                  )),
                            ]),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 100),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Use Smart Device',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(16),
                                      fontWeight: FontWeight.bold)),
                              Transform.scale(
                                  scale: 2,
                                  child: Switch(
                                    onChanged: (value) {
                                      _isUsingDevice = !_isUsingDevice;
                                      setState(() {});
                                    },
                                    value: _isUsingDevice,
                                    activeThumbColor: Colors.green[400],
                                    activeTrackColor: Colors.blueGrey,
                                    inactiveThumbColor: Colors.blueGrey[300],
                                    inactiveTrackColor: Colors.blueGrey,
                                  )),
                            ]),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 50),
                        if (_isUsingDevice)
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Smart Device Type',
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context)
                                            .textScaler
                                            .scale(16),
                                        fontWeight: FontWeight.bold)),
                                Transform.scale(
                                    scale: 2,
                                    child: DropdownButton<String>(
                                      value: dropdownValue,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent),
                                      onChanged: (String? value) {
                                        // This is called when the user selects an item.
                                        setState(() {
                                          dropdownValue = value!;
                                          if (dropdownValue == deviceTypeList[0]) {  // WiFi
                                            _isWiFiDevice = true;
                                            _isBluetoothDevice = false;
                                          } else if (dropdownValue == deviceTypeList[1]) { // Bluetooth
                                            _isWiFiDevice = false;
                                            _isBluetoothDevice = true;
                                          } else {
                                            _isWiFiDevice = false;
                                            _isBluetoothDevice = false;
                                          }
                                        });
                                      },
                                      items: deviceTypeList
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                            value: value, child: Text(value));
                                      }).toList(),
                                    )),
                              ]),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 15),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[800],
                                  elevation: 4,
                                ),
                                child: const Text('        Save        ',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () =>
                                    _validateAndSubmitForm(context),
                              ),
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
