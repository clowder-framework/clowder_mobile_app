import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../database/clowder_instance.dart';
import '../forms/create_dataset_form.dart';
import 'view_basic_data.dart';
import 'view_datasets.dart';
import 'view_spaces.dart' as spaces;
import 'homescreen.dart' as home;
import 'instance_info.dart' as instance_info;
import '../user_info.dart' as user_info;
import '../database/database_helper.dart';
import 'dart:convert';

class MainMenu extends StatelessWidget {

  String currentUserId;
  String currentInstance;
  MainMenu(this.currentUserId);

  Future<String> generateToken() async {
    String basicAuth = user_info.auth;
    String request_url = user_info.serverAddress+'/api/users/keys?name=mobile_clowder';
    http.Response token_response = await http.post(
        request_url,
        headers: {
          "Authorization": user_info.auth,
          "Content-Type": "application/json",
          "Accept": "application/json",
        });

   if (token_response.statusCode == 200){
     return "Success";
   } else {
     return "Fail";
   }
  }


  Widget myDatasets(context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 42.0,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new ViewDatasets(true, false))),
        color: Colors.blue,
        child: Text('View My Datasets', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget sharedDatasets(context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 42.0,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new ViewDatasets(false,true))),
        color: Colors.blue,
        child: Text('View Shared Datasets', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget datasetsButton(context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 42.0,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new ViewDatasets(false,false))),
        color: Colors.blue,
        child: Text('View All Datasets', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget createDatasetButton(context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 42.0,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new CreateDatasetForm(""))),
        color: Colors.blue,
        child: Text('Create New Dataset', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget viewMySpacesButton(context) {
    return new Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 42.0,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new spaces.ViewSpaces(false, false))),
        color: Colors.blue,
        child: Text('View Shared Spaces', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget viewSharedSpacesButton(context) {
    return new Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 42.0,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new spaces.ViewSpaces(false, false))),
        color: Colors.blue,
        child: Text('View Shared Spaces', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget viewSpacesButton(context) {
    return new Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 42.0,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new spaces.ViewSpaces(false, false))),
        color: Colors.blue,
        child: Text('View Spaces', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget createTokenButton(context) {
    return new Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
      child: FlatButton.icon(
        icon: Icon(Icons.assistant_photo),
        color: Colors.blue,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        textColor:  Colors.white,
        label: Text("Create Token"),
        onPressed: () =>  Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new ViewBasicData("token generation"))),
      ),
    );
  }

  Widget viewMyDatasetsIconButton(context) {
    return new Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
      child: FlatButton.icon(
        icon: Icon(Icons.folder),
        color: Colors.blue,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        textColor:  Colors.white,
        label: Text("View My Datasets"),
        onPressed: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ViewDatasets(true, false)));
        },
      ),
    );
  }

  Widget viewSharedDatasetsIconButton(context) {
    return new Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
      child: FlatButton.icon(
        icon: Icon(Icons.folder_shared),
        color: Colors.blue,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        textColor:  Colors.white,
        label: Text("View Shared Datasets"),
        onPressed: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ViewDatasets(false, true)));
        },
      ),
    );
  }

  Widget viewSpacesIconButton(context) {
    return new Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
      child: FlatButton.icon(
        icon: Icon(Icons.cloud),
        color: Colors.blue,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        textColor:  Colors.white,
        label: Text("View Spaces"),
        onPressed: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new spaces.ViewSpaces(false, false)));
        },
      ),
    );
  }

  Widget logOutButton(context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaterialButton(
        minWidth: 100.0,
        height: 42.0,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new home.MyHomeScreen())),
        color: Colors.orange,
        child: Text('Log out', style: TextStyle(color: Colors.white)),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Menu',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Main Menu'),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children : [
                Text("Welcome user " + user_info.email + " " + user_info.userName),
                Text("To Instance : " + user_info.serverAddress),
                // createTokenButton(context),
                viewMyDatasetsIconButton(context),
                viewSharedDatasetsIconButton(context),
                createDatasetButton(context),
                viewSpacesIconButton(context),
                logOutButton(context)
              ]
          )
        ),
      ),
    );
  }

}

