import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tc_chat_room/main.dart';
import 'package:tc_chat_room/views/SettingsView.dart';

class LobbyView extends StatefulWidget {
  final String currentUserId;

  LobbyView({Key key, this.currentUserId}) : super(key: key);

  @override
  _LobbyViewState createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  TextEditingController searchTextEditingController = TextEditingController();
  SharedPreferences preferences;
  QuerySnapshot resultQuery;

  lobbyTopBar({String title}) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: null,
        ),
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsView(),
                ));
          },
        ),
        IconButton(
          icon: Icon(Icons.people),
          onPressed: null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: lobbyTopBar(title: widget.currentUserId),
      body: Stack(
        children: [
          //*Background Container
          Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.orange, Colors.orange[200]],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            )),
          ),
          //*Search Bar
          Padding(
            padding: EdgeInsets.all(4.0),
            child: Container(
              margin: new EdgeInsets.only(bottom: 2.0),
              child: TextFormField(
                controller: searchTextEditingController,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                    hintText: "Search Here",
                    filled: true,
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: emptyTextFild(),
                      icon: Icon(Icons.clear),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    )),
              ),
            ),
          ),
          //*Sing Out Button
          Container(
            alignment: Alignment.center,
            child: RaisedButton.icon(
                label: Text("Sing Out"),
                onPressed: logoutUser,
                icon: Icon(
                  Icons.logout,
                )),
          )
        ],
      ),
      //*Float Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.send),
      ),
    );
  }

  emptyTextFild() {
    searchTextEditingController.clear();
  }

  //*LogOut User
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  Future<String> getUserById(String currentUserId) async {
    return preferences.getString("nickname");
  }
}
