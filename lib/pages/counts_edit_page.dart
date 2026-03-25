// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, constant_identifier_names, sized_box_for_whitespace

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tasbeeh/providers/data.dart';
import 'package:tasbeeh/util/function_util.dart';
import 'package:tasbeeh/util/lifecycle_util.dart';

class CountsEditPage extends StatefulWidget {
  static const ROUTE_NAME = '/counts-edit-page';

  @override
  _CountsEditPageState createState() => _CountsEditPageState();
}

class _CountsEditPageState extends State<CountsEditPage> {
  final _form = GlobalKey<FormState>();

  String? _count;
  String? _targetCount;
  String? _dayCount;
  String? _totalCount;
  bool _isLoading = false;
  Timer? timer;

  TextEditingController countController = TextEditingController();
  TextEditingController targetCountController = TextEditingController();
  TextEditingController dayCountController = TextEditingController();
  TextEditingController totalCountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Data data = Provider.of<Data>(context, listen: false);
    countController.text = data.count.toString();
    targetCountController.text = data.targetCount.toString();
    dayCountController.text = data.dayCount.toString();
    totalCountController.text = data.totalCount.toString();

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
    if (data.isDirty(Data.KEY_DIRTY_COUNTS_EDIT_PAGE)) {
      data.setDirty(Data.KEY_DIRTY_COUNTS_EDIT_PAGE, false);
      setState(() {});
    }
  }

  Future<void> _validateAndSubmitForm(context) async {
    if (_form.currentState?.validate() == true) {
      _form.currentState?.save();
      setState(() {
        _isLoading = true;
      });
      bool result = await Provider.of<Data>(context, listen: false).saveCounts(
          _count.toString(),
          _targetCount.toString(),
          _dayCount.toString(),
          _totalCount.toString());
      if (result) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('Saved the Counts Successfully!'),
        // ));
        FunctionUtil.showSnackBar(
            context, 'Saved the Counts Successfully!', Colors.black);
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
        title: const Text('Edit Tasbeeh Counts'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (context) => Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          color: Colors.grey,
          child: Container(
            height: MediaQuery.of(context).size.height / 2.2,
            child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Form(
                  key: _form,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      Row(children: [
                        TextFormField(
                          controller: countController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: 'Current Count',
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
                          onSaved: (value) => _count = value,
                        ),
                      ]),
                      TextFormField(
                        controller: targetCountController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Target Count'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter value for Target Count!';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => _targetCount = value,
                      ),
                      TextFormField(
                        controller: dayCountController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Today Count'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter value for Today Count!';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => _dayCount = value,
                      ),
                      TextFormField(
                        controller: totalCountController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Total Count'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter value for Total Count!';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) => _totalCount = value,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 22),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                elevation: 4,
                              ),
                              child: Text('        Save        ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context)
                                          .textScaler
                                          .scale(30))),
                              onPressed: () => _validateAndSubmitForm(context),
                            ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
