import 'package:flutter/material.dart';
import '../pages/main_menu.dart';
import '../pages/view_datasets.dart';
import '../user_info.dart';
import '../forms/create_dataset_form.dart';

class DatasetsMenuButton extends StatefulWidget {
  final BuildContext dataContext;
  final VoidCallback onPressedFunction;

  // Here I am receiving the function in constructor as params
  DatasetsMenuButton(this.onPressedFunction, this.dataContext);

  @override
  _DatasetsMenuButtonState createState() => _DatasetsMenuButtonState();
}

class _DatasetsMenuButtonState extends State<DatasetsMenuButton>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
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

  Widget getOpenActionContainer(type, icon) {
      return Container(
        child: FloatingActionButton.extended(
            heroTag: null,
          onPressed: () => Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new CreateDatasetForm(""))),
            tooltip: 'Create ' + type,
            icon: Icon(icon),
            label: Text('Create ' + type.toString().toUpperCase())),
      );
    }

  Widget getOpenActionContainerDataset(type, icon) {
    return Container(
      child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new CreateDatasetForm(""))),
          tooltip: 'Create ' + type,
          icon: Icon(icon),
          label: Text('Create ' + type.toString().toUpperCase())),
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
        tooltip: 'Create ' + type,
        child: Icon(icon),
      ),
    );
  }

  Widget getOpenActionContainerForRefresh(icon) {
    return Container(
      child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ViewDatasets(false, false))),
          tooltip: "Refresh",
          icon: Icon(icon),
          label: Text("Refresh Datasets")),
    );
  }

  Widget getClosedActionContainerForRefresh(icon) {
    return Container(
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () => Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ViewDatasets(false, false))),
          tooltip: "Refresh",
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


  Widget getOpenActionContainerForUpload(icon) {
    return Container(
      child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    new CreateDatasetForm(""))),
          tooltip: "Upload Files",
          icon: Icon(icon),
          label: Text("Upload Files")),
    );
  }

  Widget getClosedActionContainerForUpload(icon) {
    return Container(
        child: FloatingActionButton(
      heroTag: null,
      onPressed: () => Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                    new CreateDatasetForm(""))),
      tooltip: "Upload Files",
      child: Icon(icon),
    ));
  }

  Widget space() {
    return isOpened
        ? getOpenActionContainer("space", Icons.home)
        : getClosedActionContainer("space", Icons.home);
  }

  Widget collection() {
    return isOpened
        ? getOpenActionContainer("collection", Icons.book)
        : getClosedActionContainer("collection", Icons.book);
  }

  Widget dataset() {
    return isOpened
        ? getOpenActionContainer("dataset", Icons.folder)
        : getClosedActionContainer("dataset", Icons.folder);
  }

  Widget uploadFiles() {
    return isOpened
        ? getOpenActionContainerForUpload(Icons.file_upload)
        : getClosedActionContainerForUpload(Icons.file_upload);
  }

  Widget refreshDatasets() {
    return isOpened
        ? getOpenActionContainerForRefresh(Icons.adb)
        : getClosedActionContainerForRefresh(Icons.adb);
  }

  Widget mainMenu() {
    return isOpened
        ? getOpenActionContainerForMainMenu(Icons.menu)
        : getClosedActionContainerForMainMenu(Icons.menu);
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
      children: <Widget>[
              Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  _translateButton.value * 2.0,
                  0.0,
                ),
                child: mainMenu(),
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
            ]
    );
  }
}
