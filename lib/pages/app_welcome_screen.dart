import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import '../user_info.dart';
import './login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MyWelcomeScreen extends StatefulWidget {

  String instance_id;
  String existing_token;
  bool use_token;

  MyWelcomeScreen(this.existing_token, this.use_token);

  @override
  _MyAppState createState() => new _MyAppState(this.existing_token, this.use_token);
}

class _MyAppState extends State<MyWelcomeScreen> {
  String existing_token;
  bool use_token;

  _MyAppState(this.existing_token, this.use_token);
  // A splash screen widget below which loads for a while before the app runs. Displays 4CeeD logo along with message.

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 7,
      // Navigates to SignIn after loading is complete
      navigateAfterSeconds: new SignIn(this.existing_token, this.use_token),
      title: new Text('Welcome',
        style: new TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            color: Colors.white
        ),),
    );
  }
}