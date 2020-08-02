import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../user_info.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';

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
  bool fileIsImage;
  String _localPath;
  var task;
  bool isDownloading = false;
  bool isDownloaded = false;
  ReceivePort _port = ReceivePort();

  SingleFileState(this.fileId, this.fileName);

  @override
  void initState() {
    this.getFileTags();
    this.getFileDescription();
    fileIsImage = isImage();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      DownloadTaskStatus status = data[0];
      setState(() {
        if (status == DownloadTaskStatus(3)) {
          isDownloading = false;
          isDownloaded = true;
        }
      });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([status]);
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  downloadFile() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    task = await FlutterDownloader.enqueue(
      url: serverAddress + '/api/files/' + fileId + '?key=' + currentLoginToken,
      savedDir: _localPath,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: true,
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

  Future<bool> _openDownloadedFile() {
    return FlutterDownloader.open(taskId: task);
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
        body: Builder(
            builder: (ctx) => new SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    fileContainer(),
                    downloadContainer(ctx),
                    tagContainer(),
                    descriptionContainer(),
                  ],
                ))));
  }

  isImage() {
    var splitArr = fileName.split(".");
    if (splitArr.length > 0) {
      var ext = splitArr[splitArr.length - 1];
      if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
        return true;
      }
    }
    return false;
  }

  Widget fileContainer() {
    return new Container(
        padding: EdgeInsets.only(top: 20),
        color: Colors.white10,
        child: Center(
            child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: fileIsImage
                    ? CachedNetworkImage(
                        imageUrl: serverAddress +
                            '/api/files/' +
                            fileId +
                            '?key=' +
                            currentLoginToken,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error, color: Colors.amber))
                    : new Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Text(
                            "Preview not available. You can still download the file and preview it.")))));
  }

  Widget downloadContainer(BuildContext context) {
    return new Container(
        padding: EdgeInsets.only(top: 20),
        color: Colors.white10,
        child: isDownloading
            ? new Center(
                child: Chip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: Icon(Icons.access_time),
                ),
                label: Text('Downloading...'),
              ))
            : new Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                    !isDownloaded
                        ? ActionChip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade800,
                              child: Icon(Icons.file_download),
                            ),
                            label: Text('Download File'),
                            onPressed: () async {
                              downloadFile();
                              this.setState(() {
                                isDownloading = true;
                              });
                            })
                        : new Container(),
                    new Container(
                        padding: EdgeInsets.only(left: 10),
                        child: ActionChip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade800,
                              child: Icon(Icons.open_in_new),
                            ),
                            label: Text('Open File'),
                            onPressed: () async {
                              if (!isDownloaded) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('Please download the file!'),
                                ));
                              } else {
                                _openDownloadedFile().then((success) {
                                  if (!success) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content:
                                            Text('Cannot open this file')));
                                  }
                                });
                              }
                            }))
                  ])));
  }

  Widget tagContainer() {
    return new Container(
        height: 150,
        child: new Card(
            color: Colors.grey,
            shadowColor: Colors.cyan,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
                                  deleteIcon:
                                      Icon(Icons.delete, color: Colors.white54),
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
            ])));
  }

  Widget descriptionContainer() {
    return new Container(
        height: 150,
        child: new Card(
            color: Colors.grey,
            shadowColor: Colors.cyan,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
                          final String newDescr = await _asyncDescriptionDialog(
                              context, description);
                          this.updateFileDescription(newDescr);
                          this.setState(() {
                            description = newDescr;
                          });
                        }))
              ]),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: new Text(description,
                          style: new TextStyle(
                              color: Colors.white, fontSize: 20.0))))
            ])));
  }
}
