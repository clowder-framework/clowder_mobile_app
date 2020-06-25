import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'view_basic_data.dart';
import 'view_single_dataset.dart';
import 'package:async/async.dart' as async_import;
import '../user_info.dart' as user_info;

class FileUploadPage extends StatefulWidget {

  final String dataset_id;
  final String dataset_name;

  FileUploadPage(this.dataset_id, this.dataset_name);



  @override
  _FileUploadPageState createState() => _FileUploadPageState( this.dataset_id,this.dataset_name);
}

class _FileUploadPageState extends State<FileUploadPage> {
  String dataset_name;
  final String dataset_id;
  String clowderEndpoint = user_info.serverAddress+'/api/datasets/';
  String _message = "No file chosen";
  bool hasFile = false;
  File file;
  List<File> files;

  _FileUploadPageState(this.dataset_id,this.dataset_name);

  @override
  Widget build(BuildContext context) {
    if (!hasFile){
      return Scaffold(
        appBar: new AppBar(
          title: new Text("Upload File"),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Text("Upload file for dataset "  + dataset_name),
                SizedBox(width: 10.0),
                RaisedButton(
                  onPressed: _choose,
                  child: Text('Take Picture'),
                ),
                RaisedButton(
                  onPressed: _choose_existing_files,
                  child: Text('Select Multi From Anywhere'),
                ),
                SizedBox(width: 10.0),
                Text(_message),
              ]
          )
        ),
      );
    } else {
      return Scaffold(
        appBar: new AppBar(
          title: new Text(dataset_name+' '+dataset_id),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 10.0),
                RaisedButton(
                  onPressed: _clowderUpload,
                  child: Text('Upload Image'),
                ),
                SizedBox(width: 10.0),
                Text(_message),
              ]
          )
        ),
      );
    }

  }



  void _choose() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _message = "file has been chosen";
      hasFile = true;
    });
    // file = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  void _choose_existing() async {
    file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _message = "file has been chosen";
      hasFile = true;
    });

  }

  void _choose_existing_file() async {
    file = await FilePicker.getFile();
    setState(() {
      _message = "file has been chosen";
      hasFile = true;
    });

  }

  void _choose_existing_files() async {
    files = await FilePicker.getMultiFile();
    setState(() {
      _message = "multi files chosen";
      hasFile = true;
    });
  }


  void _clowderUpload() async {
    if (file == null && files == null ){
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) =>
              new ViewBasicData("fail : file null, files null")));
    } else {

      if (files == null) {
        var current_datetime = new DateTime.now();
        var stamp = current_datetime.year.toString()+'-'+current_datetime.month.toString()+
            '-'+current_datetime.day.toString()+'-'+current_datetime.hour.toString()+'-'+current_datetime.minute.toString()+current_datetime.second.toString();
        var temp_filename = 'mobile_upload_'+stamp+'.jpg';

        var imageFile = file;
        var stream = new http.ByteStream(async_import.DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();
        var uri = Uri.parse(clowderEndpoint+this.dataset_id+'/files?key='+user_info.currentLoginToken);

        var request = new http.MultipartRequest("POST", uri);
        request.headers['Authorization'] = user_info.auth;

        var multipartFile = new http.MultipartFile('file', stream, length,
            filename: temp_filename);

        request.files.add(multipartFile);


        var response = await request.send();

        if (response.statusCode == 200){
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ViewSingleDataset(this.dataset_id)));
        } else {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ViewBasicData("post file FAIL: " + clowderEndpoint+this.dataset_id+'/files?key='+user_info.currentLoginToken)));
        }
      } else {
        var count = 0;
        var uri = Uri.parse(clowderEndpoint+this.dataset_id+'/files?key='+user_info.currentLoginToken);
        var request = new http.MultipartRequest("POST", uri);
        request.headers['Authorization'] = user_info.auth;
        for (File f in files) {

          var current_datetime = new DateTime.now();
          var stamp = current_datetime.year.toString()+'-'+current_datetime.month.toString()+
              '-'+current_datetime.day.toString()+'-'+current_datetime.hour.toString()+'-'+current_datetime.minute.toString()+current_datetime.second.toString();
          var temp_filename = 'mobile_upload_'+stamp+ path.extension(f.path);

          var imageFile = f;
          var stream = new http.ByteStream(async_import.DelegatingStream.typed(imageFile.openRead()));
          var length = await imageFile.length();
          var multipartFile = new http.MultipartFile('file', stream, length,
              filename: temp_filename);

          request.files.add(multipartFile);
          count +=1;

          if (count == files.length) {
            var response = await request.send();
            if (response.statusCode == 200) {
              Navigator.push(
                        context,
                        new MaterialPageRoute(
                        builder: (BuildContext context) => new ViewSingleDataset(this.dataset_id)));
            } else {
              Navigator.push(
                    context,
                      new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new ViewBasicData("post file FAIL: " + clowderEndpoint+this.dataset_id+'/files?key='+user_info.currentLoginToken)));
            }
          }
        }
      }



    }
  }

}