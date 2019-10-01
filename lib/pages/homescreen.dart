import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'add_clowder_instance_dialog.dart';
import '../database/clowder_instance.dart';
import 'home_presenter.dart' as hp;
import 'list_clowder_instance.dart' as clist;




class MyHomeScreen extends StatefulWidget {
  MyHomeScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomeScreenState createState() => new _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> implements hp.HomeContract {
  hp.HomePresenter homePresenter;
  bool isOpened = false;

  @override
  void initState() {
    super.initState();
    homePresenter = new hp.HomePresenter(this);
  }

  displayRecord() {
    setState(() {});
  }

  Widget _buildTitle(BuildContext context) {
    var horizontalTitleAlignment =
        Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.center;

    return new InkWell(
      child: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: horizontalTitleAlignment,
          children: <Widget>[
            new Text('Clowder Instances',
              style: new TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _openAddClowderInstanceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          new AddClowderInstanceDialog().buildAboutDialog(context, this, false, null),
    );

    setState(() {});
  }
  List<Widget> _buildActions() {
    return <Widget>[
      new IconButton(
        icon: const Icon(
          Icons.group_add,
          color: Colors.white,
        ),
        // onPressed: _openAddUserDialog,
        onPressed: _openAddClowderInstanceDialog,
      ),
    ];
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
        title: _buildTitle(context),
        actions: _buildActions(),
      ),
      body: new FutureBuilder<List<ClowderInstance>>(
        future: homePresenter.getClowderInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          var data = snapshot.data;
          return snapshot.hasData
              ? new clist.ClowderInstanceList(data,homePresenter)
              : new Center(child: new CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                // onPressed: _openAddUserDialog,
                onPressed: _openAddClowderInstanceDialog,
              ),
            ],
          )
      ),
    );
  }

  @override
  void screenUpdate() {
    setState(() {});
  }
}
