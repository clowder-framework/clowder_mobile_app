import 'package:flutter/material.dart';

class ViewBasicData extends StatelessWidget {
  final String data;

  ViewBasicData(this.data);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("data display"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Text(this.data.toString()),
      ),
    );
  }

}
