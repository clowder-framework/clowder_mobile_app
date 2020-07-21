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
  bool isLoading = true;
  List files_data;
  List folders_data;
  var _tapPosition;

  SingleDatasetDataState(this.datasetId);

  Future<String> getData(String datasetId) async {
    http.Response response = await http.get(
        serverAddress +
            '/api/datasets/' +
            datasetId +
            '?key=' +
            currentLoginToken,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });

    this.setState(() {
      isLoading = false;
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
            '/api/datasets/' +
            datasetId +
            '/files?key=' +
            currentLoginToken,
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

  updateFileName(String newName, String fileId, var index) async {
    final putBody = {"name": newName};
    http.Response response = await http.put(
        serverAddress +
            '/api/files/' +
            fileId +
            '/filename?key=' +
            currentLoginToken,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(putBody));

    if (response.statusCode != 200) {
      return "Failure";
    } else {
      this.setState(() {
        files_data[index]["filename"] = newName;
      });
    }

    return "Success";
  }

  removeFile(String fileId, var index) async {
    http.Response response = await http.post(
      serverAddress +
          '/api/files/' +
          fileId +
          '/remove?key=' +
          currentLoginToken,
    );

    if (response.statusCode != 200) {
      return "Failure";
    } else {
      this.setState(() {
        files_data.removeAt(index);
      });
    }
    return "Success";
  }

  Future<String> _asyncInputDialog(BuildContext context, String currentName,
      String fileId, var index) async {
    String newName = "";
    var ext = "";

    var splitArr = currentName.split(".");
    if (splitArr.length > 0) {
      ext = splitArr[splitArr.length - 1];
    }
    newName = splitArr[0];

    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter new name (file extension will be preserved)',
            style: TextStyle(fontSize: 15),
          ),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextFormField(
                initialValue: splitArr[0],
                autofocus: true,
                onChanged: (value) {
                  newName = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                if (splitArr.length > 0) {
                  newName += "." + ext;
                }
                updateFileName(newName, fileId, index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _asyncRemoveDialog(
      BuildContext context, String fileId, var index) async {
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete this file?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                removeFile(fileId, index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Card buildCard(var data, BuildContext context, var index) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

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
            onLongPress: () => [
              showMenu(
                  context: context,
                  position: RelativeRect.fromRect(
                      _tapPosition &
                          Size(40, 40), // smaller rect, the touch area
                      Offset.zero &
                          overlay.size // Bigger rect, the entire screen
                      ),
                  items: <PopupMenuEntry>[
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.text_format),
                          Text("Rename"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete),
                          Text("Delete"),
                        ],
                      ),
                    )
                  ]).then((value) => [
                    if (value == 0)
                      {
                        _asyncInputDialog(
                            context, data["filename"], data["id"], index)
                      }
                    else if (value == 1)
                      {_asyncRemoveDialog(context, data["id"], index)}
                  ])
            ],
            leading: getIconAssociatedToType(),
            title: Text(data["filename"],
                style: new TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            subtitle: Text("file", style: new TextStyle(fontSize: 12.0)),
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new ViewSingleFile(data["id"], data["filename"])));
            },
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
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Dataset : " + dataset_name),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.cyan, strokeWidth: 5))
          : new GestureDetector(
              onTapDown: _storePosition,
              child: Container(
                  padding: EdgeInsets.only(top: 20.0),
                  color: Colors.white10,
                  child: new GridView.count(
                    primary: true,
                    padding: EdgeInsets.all(15.0),
                    crossAxisCount: 2,
                    childAspectRatio: 2.0,
                    children: List.generate(
                        files_data == null ? 0 : files_data.length, (index) {
                      return buildCard(files_data[index], context, index);
                    }),
                  ))),
      floatingActionButton:
          new SingleDatasetMenuButton(context, toggle, datasetId, dataset_name),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
