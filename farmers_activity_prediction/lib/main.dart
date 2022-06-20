import 'package:flutter/material.dart';
import 'package:farmers_activity_prediction/screens/SplashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // light status bar
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
