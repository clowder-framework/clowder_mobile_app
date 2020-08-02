import 'package:clowder_mobile_app/pages/view_single_file.dart';
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
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class FileUploadPage extends StatefulWidget {
  final String dataset_id;
  final String dataset_name;

  FileUploadPage(this.dataset_id, this.dataset_name);

  @override
  _FileUploadPageState createState() =>
      _FileUploadPageState(this.dataset_id, this.dataset_name);
}

class _FileUploadPageState extends State<FileUploadPage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String dataset_name;
  final String dataset_id;
  String fileId = "";
  String clowderEndpoint = user_info.serverAddress + '/api/datasets/';
  String _message = "No file chosen";
  bool hasFile = false;
  bool hasMultiFiles = true;
  bool isUploaded = false;
  bool isUploading = false;
  var address = "";
  File file;
  String fileName;
  List<File> files;

  _FileUploadPageState(this.dataset_id, this.dataset_name);

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.cyan, strokeWidth: 5)));
    }
    if (isUploaded) {
      return Scaffold(
        appBar: new AppBar(
          title: new Text(dataset_name + ' ' + dataset_id),
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
                child: Text('Upload Image Again'),
              ),
              SizedBox(width: 10.0),
              Text(_message),
              RaisedButton(
                onPressed: () => Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new ViewSingleDataset(this.dataset_id))),
                child: Text('Go to Dataset'),
              ),
              !hasMultiFiles
                  ? RaisedButton(
                      onPressed: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new ViewSingleFile(fileId, fileName))),
                      child: Text('Go to File'),
                    )
                  : null,
            ])),
      );
    }
    if (!hasFile) {
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
              Text("Upload file for dataset " + dataset_name),
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
            ])),
      );
    } else {
      return Scaffold(
        appBar: new AppBar(
          title: new Text(dataset_name + ' ' + dataset_id),
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
            ])),
      );
    }
  }

  void _choose() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _message = "File has been chosen";
      hasFile = true;
      hasMultiFiles = false;
    });
    // file = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  void _choose_existing() async {
    file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _message = "File has been chosen";
      hasFile = true;
    });
  }

  void _choose_existing_file() async {
    file = await FilePicker.getFile();
    setState(() {
      _message = "File has been chosen";
      hasFile = true;
    });
  }

  void _choose_existing_files() async {
    files = await FilePicker.getMultiFile();
    setState(() {
      _message = "Multi files chosen";
      hasFile = true;
      if (files.length <= 1) {
        _message = "File chosen";
        hasMultiFiles = false;
      }
    });
  }

  _getAddressFromLatLng(Position current_location) async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          current_location.latitude, current_location.longitude);

      Placemark place = p[0];
      setState(() {
        address = "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _sendMetadata(fileId, location) async {
    http.Response response = await http.post(
        user_info.serverAddress +
            '/api/files/' +
            fileId +
            '/metadata?key=' +
            user_info.currentLoginToken,
        headers: {
          "Authorization": user_info.auth,
          "Content-Type": "application/json; charset=utf-8",
          "Accept": "application/json",
        },
        body:
            json.encode({"Location": address, "LatLong": location.toString()}));
  }

  void _clowderUpload() async {
    if (file == null && files == null) {
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) =>
                  new ViewBasicData("fail : file null, files null")));
    } else {
      if (files == null) {
        var current_datetime = new DateTime.now();
        Position current_location = await geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        _getAddressFromLatLng(current_location);
        var stamp = current_datetime.year.toString() +
            '-' +
            current_datetime.month.toString() +
            '-' +
            current_datetime.day.toString() +
            '-' +
            current_datetime.hour.toString() +
            '-' +
            current_datetime.minute.toString() +
            current_datetime.second.toString();
        var temp_filename = 'mobile_upload_' + stamp + '.jpg';
        fileName = temp_filename;

        var imageFile = file;
        var stream = new http.ByteStream(
            async_import.DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();
        var uri = Uri.parse(clowderEndpoint +
            this.dataset_id +
            '/files?key=' +
            user_info.currentLoginToken);

        var request = new http.MultipartRequest("POST", uri);
        request.headers['Authorization'] = user_info.auth;

        var multipartFile = new http.MultipartFile('file', stream, length,
            filename: temp_filename);

        request.files.add(multipartFile);
        this.setState(() {
          isUploading = true;
        });

        var response = await request.send();

        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          fileId = json.decode(respStr)['id'];

          this.setState(() {
            isUploaded = true;
            _message = "File has been uploaded";
            isUploading = false;
          });
        } else {
          this.setState(() {
            isUploading = false;
          });
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new ViewBasicData(
                      "post file FAIL: " +
                          clowderEndpoint +
                          this.dataset_id +
                          '/files?key=' +
                          user_info.currentLoginToken)));
        }
      } else {
        var count = 0;
        var uri = Uri.parse(clowderEndpoint +
            this.dataset_id +
            '/files?key=' +
            user_info.currentLoginToken);
        var request = new http.MultipartRequest("POST", uri);
        request.headers['Authorization'] = user_info.auth;
        for (File f in files) {
          var current_datetime = new DateTime.now();
          var stamp = current_datetime.year.toString() +
              '-' +
              current_datetime.month.toString() +
              '-' +
              current_datetime.day.toString() +
              '-' +
              current_datetime.hour.toString() +
              '-' +
              current_datetime.minute.toString() +
              current_datetime.second.toString();
          var temp_filename = 'mobile_upload_' + stamp + path.extension(f.path);
          fileName = temp_filename;

          var imageFile = f;
          var stream = new http.ByteStream(
              async_import.DelegatingStream.typed(imageFile.openRead()));
          var length = await imageFile.length();
          var multipartFile = new http.MultipartFile('file', stream, length,
              filename: temp_filename);

          request.files.add(multipartFile);
          count += 1;

          if (count == files.length) {
            this.setState(() {
              isUploading = true;
            });
            var response = await request.send();
            if (response.statusCode == 200) {
              this.setState(() {
                isUploaded = true;
                if (!hasMultiFiles) {
                  _message = "File has been uploaded";
                } else {
                  _message = "Files have been uploaded";
                }
                isUploading = false;
              });
              var message = await response.stream.bytesToString();
              if (!hasMultiFiles) {
                fileId = json.decode(message)['id'];
              }
            } else {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new ViewBasicData(
                          "post file FAIL: " +
                              clowderEndpoint +
                              this.dataset_id +
                              '/files?key=' +
                              user_info.currentLoginToken)));
            }
          }
        }
      }
    }
  }
}
