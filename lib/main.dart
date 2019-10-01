import 'package:flutter/material.dart';
import './pages/homescreen.dart' as home;
import './pages/home_data.dart';

void main() => runApp(MyApp());

// A stateless widget to control routes in the application
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      // home: new MySplashScreen(),
        home: new home.MyHomeScreen(),
        routes: <String, WidgetBuilder> {
          // Declared all application routes below
          '/home': (BuildContext context) => new HomePageApp()
        }
    );
  }
}