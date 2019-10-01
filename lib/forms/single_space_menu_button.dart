import 'package:flutter/material.dart';
import '../pages/main_menu.dart';
import '../pages/view_spaces.dart';
import '../user_info.dart';
import '../forms/create_dataset_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SingleSpaceMenuButton extends StatefulWidget {
  final String spaceId;
  final String spaceName;
  final BuildContext dataContext;
  final VoidCallback onPressedFunction;

  SingleSpaceMenuButton(this.dataContext, this.onPressedFunction, this.spaceId, this.spaceName);

  @override
  _SingleSpaceMenuButtonState createState() => _SingleSpaceMenuButtonState(this.spaceId, this.spaceName);
}

class _SingleSpaceMenuButtonState extends State<SingleSpaceMenuButton>
    with SingleTickerProviderStateMixin {

  String spaceId;
  String spaceName;
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  Map mapData;

  _SingleSpaceMenuButtonState(this.spaceId, this.spaceName);

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


      }
    });

    return "Success";
  }

  @override
  initState() {


    this.getData(this.spaceId);

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

  Widget getOpenActionContainerViewSpaces(icon) {
    return Container(
      child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ViewSpaces(false, false))),
          tooltip: "View Spaces",
          icon: Icon(icon),
          label: Text("View Spaces")),
    );
  }

  Widget getClosedActionContainerViewSpaces(icon) {
    return Container(
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new MainMenu(userId))),
          tooltip: "View Spaces",
          child: Icon(icon),
        ));
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


  Widget getClosedActionContainer(type, icon) {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new CreateDatasetForm(spaceId))),
        tooltip: 'Create Dataset',
        child: Icon(icon),
      ),
    );
  }

  Widget getOpenActionContainer(type, icon) {
    return Container(
      child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new CreateDatasetForm(spaceId))),
          tooltip: 'Create ' + type,
          icon: Icon(icon),
          label: Text('Create ' + type.toString().toUpperCase())),
    );
  }

  Widget viewSpaces() {
    return isOpened
        ? getOpenActionContainerViewSpaces(Icons.cloud)
        : getClosedActionContainerViewSpaces(Icons.cloud);
  }


  Widget mainMenu() {
    return isOpened
        ? getOpenActionContainerForMainMenu(Icons.menu)
        : getClosedActionContainerForMainMenu(Icons.menu);
  }

  Widget dataset() {
    return isOpened
        ? getOpenActionContainer("dataset", Icons.folder)
        : getClosedActionContainer("dataset", Icons.folder);
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
            _translateButton.value * 3.0,
            0.0,
          ),
          child: mainMenu(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: viewSpaces(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: dataset(),
        ),
        toggle(),
      ],
    );
  }
}
