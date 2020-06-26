import 'dart:async';
import 'package:flutter/material.dart';
import 'view_basic_data.dart';
import 'main_menu.dart' as main_menu;
import '../user_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/database_helper.dart';
import '../database/clowder_instance.dart';


class SignIn extends StatefulWidget {

  String current_token;
  bool useToken;

  SignIn(this.current_token, this.useToken);

  @override
  State createState() => new SignInState(current_token, useToken);
}

class SignInState extends State<SignIn> {
  // Variables to store user details and flags for login
  String emailText = "", passwordText = "";
  bool isValid = false;
  bool triedLoggingIn = false;

  String current_token;
  bool useToken;

  var db = new DatabaseHelper();

  SignInState(this.current_token, this.useToken);

  Future<String> getUserInfo(basicAuth) async {
    http.Response response = await http.get(
        serverAddress+'/api/me',
        headers: {
          "Authorization": basicAuth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });
    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body);
      userId = userData["id"];
    }

    return "Success";

  }

  String generateToken()  {
    int now = new DateTime.now().millisecondsSinceEpoch;
    String token = '_'+now.toString();
    return token;
  }

  @override
  void initState() {
    super.initState();

    if (useToken){
      this._handleTokenSignIn();
    }

    //_googleSignIn.signInSilently();
  }

  showToken() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) =>
            new ViewBasicData(this.current_token)
        )
    );
  }


  Future<Null> _handleTokenSignIn() async {
    triedLoggingIn = true;
    http.Response response = await http.get(
        serverAddress+'/api/me?key='+this.current_token,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });

    if (response.statusCode == 200) {
      var content = jsonDecode(response.body);
      setState(() {
        userId = content["id"];
        isValid = true;
        email = content["email"];
        currentLoginToken = current_token;
      });

      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) =>
              new main_menu.MainMenu(userId)
          )
      );

    } else {
      setState(() {
        useToken = false;
      });
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) =>
              new main_menu.MainMenu(userId)
          )
      );
    }
  }

  Future<String> _generateNewToken() async {
    String new_token_name = generateToken();

    String request_url = serverAddress + '/api/users/keys?name=' +
        new_token_name;

    var jsonData = json.encode({
      "name": new_token_name
    });

    http.Response token_response = await http.post(
        request_url,
        body: jsonData,
        headers: {
          "Authorization": auth,
          "Content-Type": "application/json",
          "Accept": "application/json",
        });

    if (token_response.statusCode == 200) {
      var content = jsonDecode(token_response.body);
      currentLoginToken = content["key"];
      ClowderInstance current_instance = new ClowderInstance(serverAddress, content["key"]);
      current_instance.setClowderInstanceId(currentInstanceId);
      bool updated = await db.updateClowderInstance(current_instance);
      if (updated) {
        this._handleTokenSignIn();
        return "Token Success";
      }
    } else {
      return "Token Fail";
    }
  }

  Future<Null> _handleLocalSignIn() async {
    triedLoggingIn = true;

    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$emailText:$passwordText'));
    auth = basicAuth;
    http.Response response = await http.get(
        serverAddress+'/api/me',
        headers: {
          "Authorization": basicAuth,
          "Content-Type": "application/json",
          "Access-Control-Allow-Credentials": "true",
          "Access-Control-Allow-Methods": "*",
          "Content-Encoding": "gzip",
          "Access-Control-Allow-Origin": "*"
        });



    if (response.statusCode == 200) {
      setState(() {
        var content = jsonDecode(response.body);
        userId = content["id"];
        isValid = true;
        email = emailText;
        auth = basicAuth;
        this._generateNewToken();
      });
    } else {
      setState(() {
        isValid = false;
      });
    }
  }


  // A widget to allow users to sign in locally/ sign in with Google
  Widget _buildBody() {

    final email = new TextField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: new TextStyle(color: Colors.white30),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
      onChanged: (String str) {
        setState(() {
          emailText = str;
        });
      },
    );

    final password = new TextField(
        obscureText: true,
        autofocus: false,
        style: TextStyle(color: Colors.white70),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: new TextStyle(color: Colors.white30),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        ),
        onChanged: (String str) {
          setState(() {
            passwordText = str;
          });
        });

    final loginButton = new Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: MaterialButton(
        minWidth: 200.0,
        height: 42.0,
        onPressed: _handleLocalSignIn,
        color: Colors.red,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

//    final showtokenButton = new Padding(
//      padding: EdgeInsets.symmetric(vertical: 16.0),
//      child: MaterialButton(
//        minWidth: 200.0,
//        height: 42.0,
//        onPressed: showToken,
//        color: Colors.blue,
//        child: Text('View Token!', style: TextStyle(color: Colors.white)),
//      ),
//    );

    // A message preventing log in if the user entered Invalid Credentials
    final message = new Text(
      triedLoggingIn && !isValid
          ? "Please Re-enter Credentials!"
          : "",
      style:
      new TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );

    if ( isValid) {

      // TODO get api key here
      // TODO set api key for instance

      return new main_menu.MainMenu(userId);
    }
    else if (useToken) {
      return Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.cyan, strokeWidth: 5)));
    } else {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.black87,
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              message,
              new Padding(padding: EdgeInsets.only(bottom: 20.0)),
              email,
              SizedBox(height: 8.0),
              password,
              SizedBox(height: 24.0),
              loginButton,
              SizedBox(height: 24.0),
              //showtokenButton,
            ],
          ),
        ),
      );
    }
  }

  // Main widget which builds the log in page
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }

  Widget build2(BuildContext context) {
    return new Scaffold(
      body: Column(
        children: <Widget>[
          new Text("data"),
          new ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: _buildBody(),
          )
        ],
      )
    );
  }

}