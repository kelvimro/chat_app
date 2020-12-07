import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tc_chat_room/main.dart';

class ChatRoomView extends StatefulWidget {
  final String currentUserId;

  ChatRoomView({Key key, this.currentUserId}) : super(key: key);

  @override
  _ChatRoomViewState createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentUserId),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.people),
            onPressed: null,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.orange, Colors.orange[100]],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            )),
            child: Container(
              color: Colors.orange[200],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Digite uma mensagem',
                        border: InputBorder.none),
                  ))
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            child: RaisedButton.icon(
                label: Text("Sing Out"),
                onPressed: logoutUser,
                icon: Icon(
                  Icons.logout,
                )),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.send),
      ),
    );
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }
}
