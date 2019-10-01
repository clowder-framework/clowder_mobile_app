import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'view_single_dataset.dart';
import '../forms/single_space_menu_button.dart';
import 'dart:async';
import 'dart:convert';
import '../user_info.dart' as user_info;

class ViewSingleSpace extends StatefulWidget {
  final String spaceId;
  final String spaceName;

  ViewSingleSpace(this.spaceId, this.spaceName);

  @override
  State createState() => SingleSpaceDataState(spaceId, spaceName);
}

class SingleSpaceDataState extends State<ViewSingleSpace> {

  String spaceId;
  String spaceName;
  bool isOpened = false;
  Map mapData;
  List datasets_in_space;

  SingleSpaceDataState(this.spaceId, this.spaceName);


  Future<String> getDatasetsData(String spaceId) async {
    http.Response response = await http.get(
        user_info.serverAddress +
            '/api/spaces/'+spaceId+'/datasets?key='+user_info.currentLoginToken,
        headers: {
          "Authorization": user_info.auth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });

    this.setState(() {
      if (response.body == "not implemented") {

      } else {
        // data = jsonDecode(response.body);
        datasets_in_space = jsonDecode(response.body);
      }
    });

    return "Success";
  }

  @override
  void initState() {
    this.getDatasetsData(spaceId);
  }

  Icon getIconAssociatedToType(data) {
    Icon iconToReturn = Icon(Icons.folder_shared, color: Colors.tealAccent);
    if (data["authorId"] == user_info.userId) {
      iconToReturn = Icon(Icons.folder, color: Colors.tealAccent);
    }
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
              leading: getIconAssociatedToType(data),
              title: Text(
                  data["name"],
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis
              ),
              subtitle: Text(
                  "dataset",
                  style: new TextStyle(fontSize: 12.0)
              ),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new ViewSingleDataset(data["id"])));
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
        title: new Text("Space : " + spaceName),
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
            children: List.generate(datasets_in_space == null ? 0 : datasets_in_space.length, (index) {
              return buildCard(datasets_in_space[index]);
            }),
          )
      ),
      floatingActionButton: new SingleSpaceMenuButton(context,toggle, spaceId, spaceName),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

}