import 'dart:convert';

import 'package:flutter/material.dart';
import '../user_info.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class ViewSingleFile extends StatefulWidget {
  final String fileId;
  final String fileName;

  ViewSingleFile(this.fileId, this.fileName);

  @override
  State createState() => SingleFileState(fileId, fileName);
}

class SingleFileState extends State<ViewSingleFile> {
  String fileId;
  String description = "";
  String fileName;
  List tags = [];
  NetworkImage netImage;
  bool _loading = true;

  SingleFileState(this.fileId, this.fileName);

  @override
  void initState() {
    this.getFileTags();
    this.getFileDescription();
    netImage = NetworkImage(
        serverAddress + '/api/files/' + fileId + '?key=' + currentLoginToken);
    netImage.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, call) {
          this.setState(() {
            _loading = false;
          });
        },
      ),
    );
  }

  getFileTags() async {
    http.Response response = await http.get(
        serverAddress +
            '/api/files/' +
            fileId +
            '/tags?key=' +
            currentLoginToken,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });

    this.setState(() {
      if (response.statusCode == 200) {
        tags = jsonDecode(response.body)["tags"];
      }
    });

    return "Success";
  }

  addFileTag(tagName) async {
    final postBody = {
      "tags": [tagName]
    };

    http.Response response = await http.post(
        serverAddress +
            '/api/files/' +
            fileId +
            '/tags?key=' +
            currentLoginToken,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(postBody));

    this.setState(() {
      if (response.statusCode != 200) {
        tags.removeLast();
      }
    });

    return "Success";
  }

  removeFileTags(tagName) async {
    final url = Uri.parse(serverAddress +
        '/api/files/' +
        fileId +
        '/tags?key=' +
        currentLoginToken);

    var request = http.Request("DELETE", url);
    request.headers.addAll(<String, String>{
      "Authorization": auth,
      "Content-Type": "application/json",
    });

    request.body = json.encode({
      "tags": [tagName]
    });

    final response = await request.send();

    this.setState(() {
      if (response.statusCode != 200) {
        tags.add(tagName);
      }
    });

    return "Success";
  }

  getFileDescription() async {
    http.Response response = await http.get(
        serverAddress +
            '/api/files/' +
            fileId +
            '/metadata?key=' +
            currentLoginToken,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });

    this.setState(() {
      if (response.statusCode == 200)
        description = jsonDecode(response.body)["filedescription"];
    });

    return "Success";
  }

  updateFileDescription(String newDescription) async {
    final putBody = {"description": newDescription};
    print(json.encode(putBody));
    http.Response response = await http.put(
        serverAddress +
            '/api/files/' +
            fileId +
            '/updateDescription?key=' +
            currentLoginToken,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(putBody));

    print(response.statusCode);
    if (response.statusCode != 200) {
      return "Failure";
    }

    return "Success";
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    String newTag = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter new tag'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(labelText: 'Tag name'),
                onChanged: (value) {
                  newTag = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(newTag);
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _asyncDescriptionDialog(
      BuildContext context, String existing) async {
    String description = existing;
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit description'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  description = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(description);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(fileName, overflow: TextOverflow.ellipsis),
          backgroundColor: Colors.blueAccent,
        ),
        body: new SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                new Container(
                    padding: EdgeInsets.only(top: 20),
                    color: Colors.white10,
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(
                                backgroundColor: Colors.cyan, strokeWidth: 5))
                        : Center(
                            child: Container(
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Image(image: netImage)))),
                descriptionContainer(),
                tagContainer()
              ],
            )));
  }

  Widget tagContainer() {
    return new Container(
        child: tags.length > 0
            ? new Card(
                color: Colors.grey,
                shadowColor: Colors.cyan,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(
                        child: const ListTile(
                      leading: Icon(Icons.attach_file),
                      title: Text('Tags'),
                    )),
                    Container(
                        padding: EdgeInsets.only(right: 10),
                        child: ActionChip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade800,
                              child: Icon(Icons.add),
                            ),
                            label: Text('Add Tag'),
                            onPressed: () async {
                              final String newTag =
                                  await _asyncInputDialog(context);
                              this.addFileTag(newTag);
                              this.setState(() {
                                tags.add(newTag);
                              });
                            }))
                  ]),
                  Container(
                      child: SizedBox(
                          height: 50.0,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: tags.length,
                              itemBuilder: (BuildContext ctxt, int idx) {
                                return new Container(
                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    child: Chip(
                                      backgroundColor: Colors.blueAccent,
                                      deleteIcon: Icon(Icons.delete,
                                          color: Colors.white54),
                                      onDeleted: () {
                                        setState(() {
                                          this.removeFileTags(tags[idx]);
                                          tags.removeAt(idx);
                                        });
                                      },
                                      label: Text(
                                        tags[idx],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ));
                              })))
                ]))
            : new Container());
  }

  Widget descriptionContainer() {
    return new Container(
        height: 100,
        child: description.length > 0
            ? new Card(
                color: Colors.grey,
                shadowColor: Colors.cyan,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(
                        child: const ListTile(
                      leading: Icon(Icons.description),
                      title: Text('Description'),
                    )),
                    Container(
                        padding: EdgeInsets.only(right: 10),
                        child: ActionChip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade800,
                              child: Icon(Icons.edit),
                            ),
                            label: Text('Edit Description'),
                            onPressed: () async {
                              final String newDescr =
                                  await _asyncDescriptionDialog(
                                      context, description);
                              this.updateFileDescription(newDescr);
                              this.setState(() {
                                description = newDescr;
                              });
                            }))
                  ]),
                  Expanded(
                      child: new Text(description,
                          style: new TextStyle(
                              color: Colors.white, fontSize: 20.0)))
                ]))
            : new Container());
  }
}
