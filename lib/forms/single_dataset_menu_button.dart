import 'package:flutter/material.dart';
import '../pages/upload_files.dart' as upload;
import '../pages/view_datasets.dart';
import '../pages/main_menu.dart';
import '../forms/space_form.dart' as test_space;
import '../pages/view_dataset_info.dart' as ds_info;
import '../user_info.dart';
import '../forms/create_dataset_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SingleDatasetMenuButton extends StatefulWidget {
  final String dataset_id;
  final String dataset_name;
  final BuildContext dataContext;
  final VoidCallback onPressedFunction;

  SingleDatasetMenuButton(this.dataContext, this.onPressedFunction, this.dataset_id, this.dataset_name);

  @override
  _SingleDatasetMenuButtonState createState() => _SingleDatasetMenuButtonState(this.dataset_id, this.dataset_name);
}

class _SingleDatasetMenuButtonState extends State<SingleDatasetMenuButton>
    with SingleTickerProviderStateMixin {

  String dataset_id;
  String dataset_name;
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  Map mapData;

  _SingleDatasetMenuButtonState(this.dataset_id, this.dataset_name);

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

  @override
  initState() {


    this.getData(this.dataset_id);

    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    widget.onPressedFunction();
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }



  Widget getOpenActionContainerDataset(type, icon) {
    return Container(
      child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ViewDatasets(false, false))),
          tooltip: 'View Datasets',
          icon: Icon(icon),
          label: Text('View Datasets'),
      )
    );
  }

  Widget getOpenActionContainerViewSpaces(type,icon) {
    return Container(
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ds_info.ViewDatasetInfo(dataset_id, dataset_name, mapData))),
          tooltip: 'View Dataset Info',
          icon: Icon(icon),
          label: Text('View Dataset Info'),
        )
    );
  }

  Widget getOpenActionContainerManageSpaces(type,icon) {
    return Container(
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                   test_space.SpaceDropDown(this.dataset_id))),
          tooltip: 'Add To Space',
          icon: Icon(icon),
          label: Text('Add To Space'),
        )
    );
  }

  Widget getOpenActionContainerUploadFile(type,icon) {
    return Container(
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new upload.FileUploadPage(this.dataset_id,this.dataset_name))),
          tooltip: 'Upload File',
          icon: Icon(icon),
          label: Text('Upload File'),
        )
    );
  }

  Widget getClosedActionContainer(type, icon) {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new CreateDatasetForm(""))),
        tooltip: 'View Datasets',
        child: Icon(icon),
      ),
    );
  }

  Widget getOpenActionContainerForMainMenu(icon) {
    return Container(
      child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new MainMenu(userId))),
          tooltip: "Main Menu",
          icon: Icon(icon),
          label: Text("Main Menu")),
    );
  }

  Widget getClosedActionContainerForMainMenu(icon) {
    return Container(
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new MainMenu(userId))),
          tooltip: "Main Menu",
          child: Icon(icon),
        ));
  }

  Widget mainMenu() {
    return isOpened
        ? getOpenActionContainerForMainMenu(Icons.menu)
        : getClosedActionContainerForMainMenu(Icons.menu);
  }

  Widget viewDatasets() {
    return isOpened
        ? getOpenActionContainerDataset("file", Icons.folder_shared)
        : getClosedActionContainer("file", Icons.folder_shared);
  }

  Widget viewDatasetSpace() {
    return isOpened
        ? getOpenActionContainerViewSpaces("space", Icons.view_list)
        : getClosedActionContainer("space", Icons.view_list);
  }

  Widget manageSpaces() {
    return isOpened
        ? getOpenActionContainerManageSpaces("space", Icons.cloud_queue)
        : getClosedActionContainer("space", Icons.cloud_queue);
  }

  Widget uploadFile() {
    return isOpened
        ? getOpenActionContainerUploadFile("file", Icons.file_upload)
        : getClosedActionContainer("file", Icons.file_upload);
  }


  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Menu Options',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 4.0,
            0.0,
          ),
          child: mainMenu(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 3.0,
            0.0,
          ),
          child: viewDatasetSpace(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: manageSpaces(),
        ),
        Transform(
        transform: Matrix4.translationValues(
        0.0,
        _translateButton.value,
        0.0,
        ),
        child: uploadFile(),
        ),
        toggle(),
      ],
    );
  }
}
