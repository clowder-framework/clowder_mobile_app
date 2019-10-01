import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/clowder_instance.dart';
import 'dart:async';
import 'dart:convert';
import '../user_info.dart' as user_info;
import '../database/database_helper.dart';

class InstanceInfo extends StatefulWidget {
  String instanceUrl;

  InstanceInfo(this.instanceUrl);

  @override
  State createState() => InstanceInfoState(instanceUrl);
}

class InstanceInfoState extends State<InstanceInfo> {
  String instanceUrl;
  String instanceToken = "...loading";

  InstanceInfoState(this.instanceUrl);

  var db = new DatabaseHelper();

  getToken() async {
    ClowderInstance instance = await db.getClowderInstancebyURL(user_info.serverAddress.toString());
    this.instanceToken = instance.login_token;
  }

  @override
  void initState() {
    this.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Instance : " + instanceUrl),
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text("url: " + this.instanceUrl),
                  // new Expanded(child: Space2List(this.spaceNames))
                  Padding(padding: EdgeInsets.all(8.0)),
                  new Text("token :  " + this.instanceToken),
                  Padding(padding: EdgeInsets.all(8.0)),

                ]
            )
        )
    );
  }
}