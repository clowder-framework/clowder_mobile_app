import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../user_info.dart';
import 'view_single_space.dart';
import '../forms/datasets_menu_button.dart';
import '../user_info.dart' as user_info;

class ViewSpaces extends StatefulWidget {

  bool mine = false;
  bool shared = false;

  ViewSpaces(this.mine, this.shared);

  @override
  State createState() => ViewSpacesDataState(mine, shared);


}

class ViewSpacesDataState extends State<ViewSpaces> {

  bool shared;
  bool mine;

  ViewSpacesDataState(this.mine, this.shared);

  List data = [];
  bool isOpened = false;

  Future<String> getData() async {
    http.Response response = await http.get(
        serverAddress + '/api/spaces/canEdit?key='+user_info.currentLoginToken,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        }
    );

    this.setState(() {
      var result = jsonDecode(response.body);
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
    Icon iconToReturn;
    iconToReturn = Icon(Icons.cloud, color: Colors.blueGrey);
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
                  data["name"],
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis
              ),
              subtitle: Text(
                  "space",
                  style: new TextStyle(fontSize: 12.0)
              ),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new ViewSingleSpace(data["id"], data["name"])));
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
        title: new Text(
            "SPACES"),
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
          children: List.generate(data == null ? 0 : data.length, (index) {
            return buildCard(data[index]);
          }),
        ),

      ),
      floatingActionButton: new DatasetsMenuButton(toggle, context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}