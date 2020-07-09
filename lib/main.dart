import 'package:flutter/material.dart';
import './pages/homescreen.dart' as home;
import './pages/home_data.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

// void main() => runApp(MyApp());
const debug = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: debug);

  runApp(new MyApp());
}

// A stateless widget to control routes in the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        // home: new MySplashScreen(),
        home: new home.MyHomeScreen(),
        routes: <String, WidgetBuilder>{
          // Declared all application rRoutes below
          '/home': (BuildContext context) => new HomePageApp()
        });
  }
}
