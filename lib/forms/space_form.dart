import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../pages/view_basic_data.dart';
import '../pages/view_single_dataset.dart';
import '../user_info.dart';
import 'dart:async';
import 'dart:convert';

class SpaceDropDown extends StatefulWidget {


  final String title = "DropDown Demo";
  String datasetId;
  SpaceDropDown(this.datasetId);

  @override
  SpaceDropDownState createState() => SpaceDropDownState(datasetId);
}

class Space {
  String id;
  String name;

  Space(this.id, this.name);

  static List<Space> getSampleSpaces() {
    return <Space>[
      Space('1', 'space 1'),
      Space('2', 'space 2'),
      Space('3', 'space 2'),
      Space('4', 'space 4'),
      Space('5', 'space 5'),
    ];
  }
}

class SpaceDropDownState extends State<SpaceDropDown> {
  //

  String message = "init";

  String datasetId;
  Map mapData;
  String datasetName = "";
  List dataset_spaces = [];
  List<Space> _spaces_of_dataset = [];
  List<Space> _available_spaces = [];

  var space_data = [];

  List<Space> _spaces = Space.getSampleSpaces();
  List<DropdownMenuItem<Space>> _dropdownMenuItems;
  Space _selectedSpace;

  SpaceDropDownState(this.datasetId);

  Future<String> getDatasetData(String datasetId) async {
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



    if (response.statusCode == 200){
      this.setState(() {
        if (response.body == "not implemented") {
          mapData['name'] = "noname";
        } else {
          mapData = jsonDecode(response.body);
          datasetName = mapData["name"];
          dataset_spaces = mapData["spaces"];

        }
      });
    }
  }

  getAllSpaces() async {
    http.Response response =
    await http.get(serverAddress + '/api/spaces?key='+currentLoginToken
        , headers: {
      "Authorization": auth,
    });

    if (response.statusCode == 200) {
      this.setState(() {
        message = "all spaces, 200";
        space_data = jsonDecode(response.body);
        if (dataset_spaces.length > 0){
          message = "200, in at least a space";
        }
        for (var s in space_data) {
          if (!dataset_spaces.contains(s["id"])){
            var current_space = new Space(s["id"],s["name"]);
            _available_spaces.add(current_space);
          }
        }
        _dropdownMenuItems = buildDropdownMenuItems(_available_spaces);
        _selectedSpace = _dropdownMenuItems[0].value;
      });

    }
  }

  getSpaces() async {
    http.Response response =
    await http.get(serverAddress + '/api/spaces?key='+currentLoginToken, headers: {
      "Authorization": auth,
    });

    if (response.statusCode == 200){
      message = "at least 200";
      setState(() {
        space_data = jsonDecode(response.body);
        dataset_spaces = mapData["spaces"];
        var num_dataset_spaces = dataset_spaces.length;
        var available = space_data.length - num_dataset_spaces;
        message = "total: " + space_data.length.toString() + " available : " + available.toString();
        if (space_data.length > 0){
          var checked_spaces = 0;
          for (var s in space_data){
            checked_spaces += 1;
            if (!dataset_spaces.contains(s["id"])){
              var current_space = new Space(s["id"],s["name"]);
              _available_spaces.add(current_space);
            } else {
              var current_space = new Space(s["id"], s["name"]);
              _spaces_of_dataset.add(current_space);
            }
            if (checked_spaces == space_data.length){
              message = "we checked all";
              _dropdownMenuItems = buildDropdownMenuItems(_available_spaces);
              _selectedSpace = _dropdownMenuItems[0].value;
            }
          }
        } else  {
          message = "something wrong";
          var checked_spaces = 0;
          for (var s in space_data) {
            checked_spaces += 1;
            var current_space = new Space(s["id"], s["name"]);
            _available_spaces.add(current_space);
            if (checked_spaces == space_data.length){
              message = "we checked all";
              _dropdownMenuItems = buildDropdownMenuItems(_available_spaces);
              _selectedSpace = _dropdownMenuItems[0].value;
            }
          }
        }


      });
      return "Success";
    }
  }

  addDatasetToSpace(dataset_id, space_id) async {
    http.Response response = await http.post(serverAddress + '/api/spaces/'+space_id+'/addDatasetToSpace/'+dataset_id+'?key='+currentLoginToken);

    if (response.statusCode == 200) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) =>
              new ViewSingleDataset(dataset_id)));
    } else {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) =>
              new ViewBasicData(serverAddress + '/api/spaces/'+space_id+'/addDatasetToSpace/'+dataset_id+'?key='+currentLoginToken)));
    }
  }

  @override
  void initState() {
    _dropdownMenuItems = buildDropdownMenuItems(_spaces);
    _selectedSpace = _dropdownMenuItems[0].value;
    this.getDatasetData(datasetId);
    this.getAllSpaces();
    //this.getSpaces();

    super.initState();
  }


  List<DropdownMenuItem<Space>> buildDropdownMenuItems(List spaces) {
    List<DropdownMenuItem<Space>> items = List();
    for (Space space in spaces) {
      items.add(
        DropdownMenuItem(
          value: space,
          child: Text(space.name),
        ),
      );
    }
    return items;
  }

  onChangeDropdownItem(Space selectedSpace) {
    setState(() {
      _selectedSpace = selectedSpace;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Add to Space"),
        ),
        body: new Container(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Dataset :",
                  textScaleFactor: 2.0,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(datasetName,
                  textScaleFactor: 2.0,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text("Add To New Space",
                  textScaleFactor: 1.5,
                  ),
                SizedBox(
                  height: 20.0,
                ),
                DropdownButton(
                  value: _selectedSpace,
                  items: _dropdownMenuItems,
                  onChanged: onChangeDropdownItem,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text('Selected: ${_selectedSpace.name}'),
                new MaterialButton(
                  onPressed: () =>addDatasetToSpace(datasetId, _selectedSpace.id),
                  color: Colors.green,
                  child: Text('Add To Space', style: TextStyle(color: Colors.white))
                ),
                SizedBox(
                  height: 20.0,
                ),
                new MaterialButton(
                    onPressed: () => Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new ViewSingleDataset(datasetId))),
                    color: Colors.red,
                    child: Text('Cancel', style: TextStyle(color: Colors.white))
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
