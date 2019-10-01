import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'add_clowder_instance_dialog.dart';
import '../database/clowder_instance.dart';
import 'home_presenter.dart';
import 'view_basic_data.dart';
import 'app_welcome_screen.dart';
import '../user_info.dart' as user_info;


class ClowderInstanceList extends StatelessWidget {
  List<ClowderInstance> instance;
  HomePresenter homePresenter;

  ClowderInstanceList(
    List<ClowderInstance> this.instance,
    HomePresenter this.homePresenter, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemCount: instance == null ? 0 : instance.length,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new Container(
                child: new Center(
                  child: new Row(
                    children: <Widget>[
                      OutlineButton(
                        onPressed: () {
                          user_info.serverAddress = instance[index].url;
                          user_info.currentInstanceId = instance[index].id;
                          user_info.currentLoginToken = instance[index].login_token;
                          if (instance[index].login_token == ""){
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                    new MyWelcomeScreen(instance[index].login_token, false)));
                          } else {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                    new MyWelcomeScreen(instance[index].login_token, true)));
                          }
                        },
                        child: Text("Log In"),
                        borderSide: BorderSide(color: Colors.blue),
                        shape: StadiumBorder(),
                      ),
//                      new CircleAvatar(
//                        radius: 30.0,
//                        child: new Text("log in"),
//                        backgroundColor: const Color(0xFF20283e),
//                      ),
                      new Expanded(
                        child: new Padding(
                          padding: EdgeInsets.all(10.0),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text(
                                instance[index].url,
                                // set some style to text
                                style: new TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.lightBlueAccent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                         new IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: const Color(0xFF167F67),
                              ),
                              onPressed: () => edit(instance[index], context),
                            ),

                          new IconButton(
                            icon: const Icon(Icons.delete_forever,
                                color: const Color(0xFF167F67)),
                            onPressed: () =>
                                homePresenter.deleteClowderInstance(instance[index]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0)),
          );
        });
  }

  displayRecord() {
    homePresenter.updateScreen();
  }
  edit(ClowderInstance instance, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          new AddClowderInstanceDialog().buildAboutDialog(context, this, true, instance),
    );
    homePresenter.updateScreen();
  }

  String getShortName(ClowderInstance instance) {
    return instance.url;
  }
}
