import 'package:flutter/material.dart';
import '../user_info.dart';

class ViewSingleFile extends StatefulWidget {
  final String fileId;
  final String fileName;

  ViewSingleFile(this.fileId, this.fileName);

  @override
  State createState() => SingleFileState(fileId, fileName);
}

class SingleFileState extends State<ViewSingleFile> {
  String fileId;
  String fileName;
  NetworkImage netImage;
  bool _loading = true;

  SingleFileState(this.fileId, this.fileName);

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(fileName, overflow: TextOverflow.ellipsis),
          backgroundColor: Colors.blueAccent,
        ),
        body: new Container(
            color: Colors.white10,
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.cyan, strokeWidth: 5))
                : Center(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Image(image: netImage)))));
  }
}
