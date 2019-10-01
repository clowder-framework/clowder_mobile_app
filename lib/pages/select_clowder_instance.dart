import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'view_basic_data.dart' as basic_data;
import 'dart:async';
import 'package:flutter/services.dart';


class SelectClowderInstance extends StatefulWidget {
  @override
  _SelectClowderState createState() => new _SelectClowderState();
}

class _SelectClowderState extends State<SelectClowderInstance> {

  String currentInstance;

  _read() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/conf.txt');
      String text = await file.readAsString();
      print(text);
    } catch (e) {
      print("Couldn't read file");
    }
  }

  _save() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/conf.txt');
    final text = 'Hello World!';
    await file.writeAsString(text);
    print('saved');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
  Future<String> _readInstance() async {
    try {
      File file = await _getLocalFile();
      // read the variable as a string from the file.
      String contents = await file.readAsString();
      return contents;
    } on FileSystemException {
      return "0";
    }
  }

  Future<File> _getLocalFile() async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/conf.txt');
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/conf.txt');
  }

  Future<File> writeName() async {

    // Write the file
    await (await _getLocalFile()).writeAsString(currentInstance);
  }


  _handleSelect() {
    print("nothing");
  }

  @override
  void initState() {
    super.initState();
    _readInstance().then((String value) {
      setState(() {
        currentInstance = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Menu',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Main Menu'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children : [
                  Text("Input the URL of your instance"),
                  new TextField(
                    keyboardType: TextInputType.url,
                    autofocus: false,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'URL',
                      hintStyle: new TextStyle(color: Colors.black),
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    ),
                    onChanged: (String str) {
                      setState(() {
                        currentInstance = str;
                      });
                    },
                  ),
                  new RaisedButton(
                      onPressed: _read,
                      child: Text("Read")
                  ),
                  new RaisedButton(
                      onPressed: _save,
                      child: Text("WRite")
                  ),
                  RaisedButton(
                    onPressed: () => Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new basic_data.ViewBasicData(_localFile.toString()))),
                    child: Text('Save name Image'),
                  )
                ]
            )
        ),
      ),
    );
  }

}