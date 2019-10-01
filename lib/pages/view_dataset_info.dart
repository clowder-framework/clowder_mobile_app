import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../user_info.dart' as user_info;
import '../forms/single_dataset_menu_button.dart';

class ViewDatasetInfo extends StatefulWidget {
  final datasetId;
  final datasetName;
  Map mapData;

  ViewDatasetInfo(this.datasetId, this.datasetName, this.mapData);

  @override
  State createState() => ViewDatasetInfoState(datasetId, datasetName, mapData);

}

class ViewDatasetInfoState extends State<ViewDatasetInfo> {
  String datasetId;
  String datasetName;
  Map mapData;
  var space_data;
  List<String> spaceIds = [];
  List<String> spaceNames = [];
  String authorName;
  bool isOpened = false;

  ViewDatasetInfoState(this.datasetId, this.datasetName, this.mapData);

  getAllSpaces() async {
    http.Response response =
    await http.get(user_info.serverAddress + '/api/spaces?key='+user_info.currentLoginToken, headers: {
      "Authorization": user_info.auth,
    });

    if (response.statusCode == 200) {
      this.setState(() {
        space_data = jsonDecode(response.body);
        for (var sp in space_data) {
          if (spaceIds.contains(sp["id"])){
            spaceNames.add(sp["name"]);
          }
        }
      });

    }
  }


  getDatasetSpaces()  {
    for (var s in mapData["spaces"]){
      spaceIds.add(s);
    }
  }

  void toggle() {
    this.setState(() {
      isOpened = !isOpened;
    });
    print(isOpened);
  }

  @override
  void initState() {

    this.getDatasetSpaces();
    this.getAllSpaces();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Dataset : " + datasetName),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text("Dataset name : " + mapData["name"]),
              // new Expanded(child: Space2List(this.spaceNames))
              Padding(padding: EdgeInsets.all(8.0)),
              new Text("Dataset is in the following spaces : "),
              Padding(padding: EdgeInsets.all(8.0)),
              Expanded(child:
                  Container(
                    child: ListView.builder(
                      itemCount: spaceNames.length,
                      itemBuilder: (context, int){
                        // return new Text(spaceNames[int]);
                        return new Center(
                          child: Text(spaceNames[int])
                        );
                      },
                    )
                  )
              )
            ]
        )
      )
    );
  }
}

class SpaceList extends StatelessWidget {
  // Builder methods rely on a set of data, such as a list.
  final List<String> spaces = ["Space one", "Space 2", "Space 3"];

  // First, make your build method like normal.
  // Instead of returning Widgets, return a method that returns widgets.
  // Don't forget to pass in the context!
  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  // A builder method almost always returns a ListView.
  // A ListView is a widget similar to Column or Row.
  // It knows whether it needs to be scrollable or not.
  // It has a constructor called builder, which it knows will
  // work with a List.

  ListView _buildList(context) {
    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: spaces.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
        // In our case, a DogCard for each doggo.
        return new Text(spaces[int]);
      },
    );
  }
}


class Space2List extends StatelessWidget {
  // Builder methods rely on a set of data, such as a list.
  final List<String> spaces2 = ["1 space", "2 space", "3 space"];
  List<String> datasetSpaceNames;

  Space2List(this.datasetSpaceNames);

  // First, make your build method like normal.
  // Instead of returning Widgets, return a method that returns widgets.
  // Don't forget to pass in the context!
  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  // A builder method almost always returns a ListView.
  // A ListView is a widget similar to Column or Row.
  // It knows whether it needs to be scrollable or not.
  // It has a constructor called builder, which it knows will
  // work with a List.

  ListView _buildList(context) {
    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: datasetSpaceNames.length,
      // A callback that will return a widget.
      itemBuilder: (context, int) {
        // In our case, a DogCard for each doggo.
        return new Text(datasetSpaceNames[int]);
      },
    );
  }
}