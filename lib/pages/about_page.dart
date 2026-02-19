// ignore_for_file: sort_child_properties_last, use_key_in_widget_constructors, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/function_util.dart';

class AboutPage extends StatelessWidget {
  static const ROUTE_NAME = '/about-page';

  @override
  Widget build(BuildContext context) {
    final double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final double fontSize =
        (MediaQuery.of(context).size.width >= 380 ? 20 : 15) / textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('About Smart Tasbeeh'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Hero(
                tag: 'about-water',
                child: Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: InkWell(
                      child: Image.asset('assets/images/logo.png'),
                      onTap: () {
                        try {
                          launchUrl(Uri.https('alithistech.com', '/', {}));
                        } catch (error) {
                          FunctionUtil.showErrorSnackBar(context);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            InkWell(
              child: Text(
                'alithistech.com',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () {
                try {
                  launchUrl(Uri.https('alithistech.com', '/', {}));
                } catch (error) {
                  FunctionUtil.showErrorSnackBar(context);
                }
              },
            ),
            const Divider(
              height: 40,
            ),
            InkWell(
              child: Text(
                'mohammad.mujeeb@gmail.com',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () {
                try {
                  launchUrl(Uri.http('mailto:mohammad.mujeeb@gmail.com', ''));
                } catch (error) {
                  FunctionUtil.showErrorSnackBar(context);
                }
              },
            ),
            const SizedBox(height: 20),
            InkWell(
              child: Text(
                '+91 9880506766',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () {
                try {
                  launchUrl(Uri.http('tel:+919880506766', ''));
                } catch (error) {
                  FunctionUtil.showErrorSnackBar(context);
                }
              },
            ),
            const Divider(
              height: 40,
            ),
            ElevatedButton(
              child: const Text('        Close        '),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
