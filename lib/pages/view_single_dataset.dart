import 'package:clowder_mobile_app/pages/view_single_file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../user_info.dart';
import '../forms/single_dataset_menu_button.dart';

class ViewSingleDataset extends StatefulWidget {
  final String datasetId;

  ViewSingleDataset(this.datasetId);

  @override
  State createState() => SingleDatasetDataState(datasetId);
}

class SingleDatasetDataState extends State<ViewSingleDataset> {

  String datasetId;
  String dataset_name = "loading...";
  bool isOpened = false;
  Map mapData;
  List files_data;
  List folders_data;

  SingleDatasetDataState(this.datasetId);

  Future<String> getData(String datasetId) async {
    http.Response response = await http.get(
        serverAddress +
            '/api/datasets/'+datasetId+'?key='+currentLoginToken,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });

    this.setState(() {
      if (response.body == "not implemented") {
        mapData['name'] = "noname";
      } else {
        mapData = jsonDecode(response.body);
        this.dataset_name = mapData["name"];


      }
    });

    return "Success";
  }

  Future<String> getFileData(String datasetId) async {
    http.Response response = await http.get(
        serverAddress +
            '/api/datasets/'+datasetId+'/files?key='+currentLoginToken,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });

    this.setState(() {
      if (response.body == "not implemented") {
        files_data = ["400"];
      } else {
        // data = jsonDecode(response.body);
        files_data = jsonDecode(response.body);
      }
    });

    return "Success";
  }

  @override
  void initState() {
    this.getData(datasetId);
    this.getFileData(datasetId);
  }

  Icon getIconAssociatedToType() {
    Icon iconToReturn;
    iconToReturn = Icon(Icons.insert_drive_file, color: Colors.tealAccent);
    return iconToReturn;
  }

  Card buildCard(var data) {
    var customCard = new Card(
      elevation: 5.0,
      margin: EdgeInsets.all(2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              leading: getIconAssociatedToType(),
              title: Text(
                  data["filename"],
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis
              ),
              subtitle: Text(
                  "file",
                  style: new TextStyle(fontSize: 12.0)
              ),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new ViewSingleFile(data["id"], data["filename"])));
              }
          ),
        ],
      ),
    );
    return customCard;
  }

  void toggle() {
    this.setState(() {
      isOpened = !isOpened;
    });
    print(isOpened);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Dataset : " + dataset_name),
          backgroundColor: Colors.blueAccent,
        ),
        body: new Container(
            padding: EdgeInsets.only(top: 20.0),
            color: Colors.white10,
            child: new GridView.count(
              primary: true,
              padding: EdgeInsets.all(15.0),
              crossAxisCount: 2,
              childAspectRatio: 2.0,
              children: List.generate(files_data == null ? 0 : files_data.length, (index) {
                return buildCard(files_data[index]);
              }),
            )
        ),
        floatingActionButton: new SingleDatasetMenuButton(context,toggle, datasetId, dataset_name),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

}