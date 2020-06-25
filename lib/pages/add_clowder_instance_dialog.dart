import 'dart:async';
import '../database/clowder_instance.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddClowderInstanceDialog {
  final teURL = TextEditingController(text: "https://");
  final teToken = TextEditingController();
  ClowderInstance instance;

  static const TextStyle linkStyle = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  Widget buildAboutDialog(
      BuildContext context, _myHomePageState, bool isEdit, ClowderInstance instance) {
    if (instance != null) {
      this.instance=instance;
      teURL.text = instance.url;
      teToken.text = instance.login_token;
    }

    return new AlertDialog(
      title: new Text(isEdit ? 'Edit' : 'Add new Instance'),
      content: new SingleChildScrollView(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getTextField("URL of instance", teURL),
            // getTextField("Token", teToken),
            new GestureDetector(
              onTap: () {
                addRecord(isEdit);
                _myHomePageState.displayRecord();
                Navigator.of(context).pop();
              },
              child: new Container(
                margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: getAppBorderButton(
                    isEdit?"Edit":"Add", EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTextField(
      String inputBoxName, TextEditingController inputBoxController) {
    var loginBtn = new Padding(
      padding: const EdgeInsets.all(5.0),
      child: new TextFormField(
        controller: inputBoxController,
        decoration: new InputDecoration(
          hintText: inputBoxName,
        ),
      ),
    );

    return loginBtn;
  }

  Widget getAppBorderButton(String buttonLabel, EdgeInsets margin) {
    var loginBtn = new Container(
      margin: margin,
      padding: EdgeInsets.all(8.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        border: Border.all(color: const Color(0xFF28324E)),
        borderRadius: new BorderRadius.all(const Radius.circular(6.0)),
      ),
      child: new Text(
        buttonLabel,
        style: new TextStyle(
          color: const Color(0xFF28324E),
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.3,
        ),
      ),
    );
    return loginBtn;
  }

  Future addRecord(bool isEdit) async {
    var db = new DatabaseHelper();
    var instance = new ClowderInstance(teURL.text, teToken.text);
    if (isEdit) {
      instance.setClowderInstanceId(this.instance.id);
      await db.updateClowderInstance(instance);
    } else {
      await db.saveClowderInstance(instance);
    }
  }
}
