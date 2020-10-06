import 'package:flutter/material.dart';

import 'home_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting("ja_JP");
  runApp(MyApp());
}

final appTitle = 'Kinkan';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Builder(builder: (BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      child: Image(
                          image: AssetImage('assets/kinkan.png'),
                          fit: BoxFit.cover),
                    ),
                    Text(appTitle,
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.info),
                  color: Colors.blueGrey,
                  onPressed: () =>
                      showAboutDialog(
                        context: context,
                        applicationName: '1.0.2',
                        applicationVersion: 'Kinkan',
                      ),
                ),
              ],
              centerTitle: true,
              backgroundColor: Colors.white,
            ),
            body: HomePage());
      }),
    );
  }
}
