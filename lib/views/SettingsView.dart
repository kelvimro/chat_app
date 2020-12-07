import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tc_chat_room/main.dart';
import 'package:tc_chat_room/widgets/progress_widget.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Text("Settings"),
      ),
      body: _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  TextEditingController nicknameTextEditingController;
  TextEditingController aboutMeTextEditingController;

  SharedPreferences preferences;
  String id = "";
  String nickname = "";
  String photoUrl = "";
  String aboutMe = "";
  File photoFile;
  bool isLoading = false;
  final FocusNode nicknameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    readDataFromLocal();
    setState(() {
      isLoading = true;
    });
  }

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    nickname = preferences.getString("nickname");
    photoUrl = preferences.getString("photoUrl");
    aboutMe = preferences.getString("aboutMe");

    nicknameTextEditingController = TextEditingController(text: nickname);
    aboutMeTextEditingController = TextEditingController(text: aboutMe);

    setState(() {
      isLoading = false;
    });
  }

  Future getImage() async {
    File newImageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newImageFile != null) {
      setState(() {
        photoFile = newImageFile;
      });
    }
  }

  //uploadImageToFireStore(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //*Profile image
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(4.0),
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        (photoFile == null)
                            ? (photoUrl != "")
                                //* Display existing old photo
                                ? Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.orangeAccent[100]),
                                        ),
                                        width: 200.0,
                                        height: 200.0,
                                        padding: EdgeInsets.all(20.0),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      imageUrl: photoUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(125.0)),
                                    clipBehavior: Clip.hardEdge,
                                  )
                                //*Show an icon while don't have photo
                                : Icon(
                                    Icons.account_circle,
                                    size: 200.0,
                                    color: Colors.orangeAccent,
                                  )
                            //* Display updated photo
                            : Material(
                                child: Image.file(
                                  photoFile,
                                  width: 200.0,
                                  height: 200.0,
                                ),
                              ),
                        //*Photo change icon
                        IconButton(
                          alignment: Alignment.center,
                          icon: Icon(
                            Icons.camera_alt,
                            size: 50.0,
                            color: Colors.white54,
                          ),
                          onPressed: getImage,
                          padding: EdgeInsets.all(0.0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.grey,
                          iconSize: 200.0,
                        ),
                      ],
                    ),
                  ),
                ), //*Image Profile end
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: isLoading ? circularProgress() : Container(),
                    ),
                    //*Nickname
                    Container(
                      padding: EdgeInsets.only(right: 30.0, left: 30.0),
                      child: Theme(
                        data: Theme.of(context),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Enter your Nickname",
                            labelText: "Nickname",
                            contentPadding: EdgeInsets.all(5.0),
                          ),
                          controller: nicknameTextEditingController,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: nicknameFocusNode,
                        ),
                      ),
                    ), //*Nickname end
                    //*About Me
                    Container(
                      padding: EdgeInsets.only(right: 30.0, left: 30.0),
                      child: Theme(
                        data: Theme.of(context),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Tell about you.",
                            labelText: "About Me",
                            contentPadding: EdgeInsets.all(5.0),
                          ),
                          controller: aboutMeTextEditingController,
                          onChanged: (value) {
                            aboutMe = value;
                          },
                          focusNode: aboutMeFocusNode,
                        ),
                      ),
                    ), //*About me end
                  ],
                ), //*TextFields column
                //*Buttons
                Container(
                  child: FlatButton(
                    onPressed: () {},
                    child: Text("Update"),
                    color: Colors.orangeAccent,
                    highlightColor: Colors.red,
                    splashColor: Colors.transparent,
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                  ),
                  margin: EdgeInsets.only(top: 30.0, bottom: 5.0),
                ),
                //*Logout Button
                Padding(
                  padding: EdgeInsets.only(
                    left: 50.0,
                    right: 50.0,
                  ),
                  child: RaisedButton(
                    onPressed: logoutUser,
                    child: Text("Logout"),
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  //*LogOut User
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
