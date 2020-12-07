import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                ), //*Image Profile and
              ],
            ),
          )
        ],
      ),
    );
  }
}
