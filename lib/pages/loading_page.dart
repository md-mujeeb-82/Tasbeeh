// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:tasbeeh/pages/home_page.dart';
import 'package:tasbeeh/util/provider_util.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ProviderUtil.loadAllProviders(context),
      builder: (ctx, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? MMScaffold(const CircularProgressIndicator()).widget()
              : snapshot.data == true
                  ? HomePage()
                  : MMScaffold(
                      const Text(
                        'An error has Occured. Please make sure that you are connected to Internet.',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ).widget(),
    );
  }
}

class MMScaffold {
  final Widget _child;

  MMScaffold(this._child);

  Widget widget() {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Smart Tasbeeh'),
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        body: Center(child: _child));
  }
}
