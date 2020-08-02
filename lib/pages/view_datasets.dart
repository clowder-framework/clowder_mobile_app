import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../user_info.dart';
import 'view_single_dataset.dart';
import '../forms/datasets_menu_button.dart';
import '../user_info.dart' as user_info;

class ViewDatasets extends StatefulWidget {
  bool mine = false;
  bool shared = false;

  ViewDatasets(this.mine, this.shared);

  @override
  State createState() => DatasetsDataState(mine, shared);
}

class DatasetsDataState extends State<ViewDatasets> {
  bool shared;
  bool mine;
  String header = "Datasets";
  bool isLoading = true;

  DatasetsDataState(this.mine, this.shared);

  List data = [];
  bool isOpened = false;

  Future<String> getData() async {
    http.Response response = await http.get(
        serverAddress +
            '/api/datasets/canEdit?key=' +
            currentLoginToken +
            '&limit=50',
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });

    this.setState(() {
      if (mine) {
        header = "My Datasets";
      } else if (shared) {
        header = "Shared Datasets";
      }
      var result = jsonDecode(response.body);
      isLoading = false;
      for (var r in result) {
        if (mine) {
          if (r["authorId"] == user_info.userId) {
            data.add(r);
          }
        } else if (shared) {
          if (r["authorId"] != user_info.userId) {
            data.add(r);
          }
        } else {
          data.add(r);
        }
      }
      // data = jsonDecode(response.body);
    });

    return "Success";
  }

  @override
  void initState() {
    this.getData();
  }

  Icon getIconAssociatedToType() {
    if (mine) {
      Icon iconToReturn;
      iconToReturn = Icon(Icons.folder, color: Colors.blueGrey);
      return iconToReturn;
    } else if (shared) {
      Icon iconToReturn;
      iconToReturn = Icon(Icons.folder_shared, color: Colors.blueGrey);
      return iconToReturn;
    } else {
      Icon iconToReturn;
      iconToReturn = Icon(Icons.folder, color: Colors.blueGrey);
      return iconToReturn;
    }
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
              title: Text(data["name"],
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
              subtitle: Text("dataset", style: new TextStyle(fontSize: 12.0)),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new ViewSingleDataset(data["id"])));
              }),
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
        title: new Text(header),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.cyan, strokeWidth: 5))
          : new Container(
              padding: EdgeInsets.only(top: 20.0),
              color: Colors.white10,
              child: new GridView.count(
                primary: true,
                padding: EdgeInsets.all(15.0),
                crossAxisCount: 2,
                childAspectRatio: 2.0,
                children:
                    List.generate(data == null ? 0 : data.length, (index) {
                  return buildCard(data[index]);
                }),
              ),
            ),
      floatingActionButton: new DatasetsMenuButton(toggle, context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
