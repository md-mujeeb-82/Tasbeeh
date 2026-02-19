import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:tasbeeh/pages/about_page.dart';
import 'package:tasbeeh/pages/config_edit_page.dart';
import 'package:tasbeeh/pages/counts_edit_page.dart';
import 'package:tasbeeh/pages/home_page.dart';
import 'package:tasbeeh/pages/loading_page.dart';
import 'package:tasbeeh/pages/smart_device_page%20.dart';
import 'package:tasbeeh/providers/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(const TasbeehApp()));
}

class TasbeehApp extends StatelessWidget {
  const TasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.debugCheckInvalidValueType = null;

    return MultiProvider(
      providers: [
        Provider<Data>(create: (_) => Data()),
      ],
      child: MaterialApp(
        title: 'Smart Tasbeeh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: ColorScheme.fromSwatch(accentColor: Colors.brown),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (ctx) => LoadingPage(),
          HomePage.ROUTE_NAME: (ctx) => HomePage(),
          AboutPage.ROUTE_NAME: (ctx) => AboutPage(),
          CountsEditPage.ROUTE_NAME: (ctx) => CountsEditPage(),
          ConfigEditPage.ROUTE_NAME: (ctx) => ConfigEditPage(),
          SmartDevicePage.ROUTE_NAME: (ctx) => SmartDevicePage(),
        },
      ),
    );
  }
}
