import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../user_info.dart';

class ViewSingleFile extends StatefulWidget {
  final String fileId;

  ViewSingleFile(this.fileId);

  @override
  State createState() => SingleFileState(fileId);
}

class SingleFileState extends State<ViewSingleFile> {
  String fileId;
  NetworkImage netImage;
  bool loading = false;

  SingleFileState(this.fileId);

  @override
  void initState() {
    this.getData(fileId);
  }

  Future<Null> getData(String fileId) async {
    this.setState(() {
      loading = true;
    });
    netImage = NetworkImage(
        serverAddress + '/api/files/' + fileId + '?key=' + currentLoginToken);
    this.setState(() {
      loading = false;
    });
  }

  // Widget currentState() {
  //   if (loading) {
  //     return new Container(
  //         child: Center(
  //             child: CircularProgressIndicator(
  //                 backgroundColor: Colors.cyan, strokeWidth: 5)));
  //   } else {
  //     return new Container(
  //         padding: EdgeInsets.only(top: 20.0),
  //         color: Colors.white10,
  //         child: Image(image: netImage));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("File"),
          backgroundColor: Colors.blueAccent,
        ),
        body: new Container(
          padding: EdgeInsets.only(top: 20.0),
          color: Colors.white10,
          child: Image(image: netImage)));
  }
}
