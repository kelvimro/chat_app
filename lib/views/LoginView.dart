import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tc_chat_room/views/LobbyView.dart';
import 'package:tc_chat_room/widgets/google_signin_widget.dart';
import 'package:tc_chat_room/widgets/progress_widget.dart';

class LoginView extends StatefulWidget {
  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;

  bool isLogedIn = false;
  bool isLoading = false;
  User currentUser;

  @override
  void initState() {
    super.initState();
  }

  void isSignedIn() async {
    this.setState(() {
      isLogedIn = true;
    });

    preferences = await SharedPreferences.getInstance();
    isLogedIn = await googleSignIn.isSignedIn();

    if (isLogedIn) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LobbyView(currentUserId: preferences.getString("id"))));
    }
    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.orange, Colors.orange[100]],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "Stik",
              style: TextStyle(fontSize: 82.0, color: Colors.black),
            ),
            GestureDetector(
              onTap: controlSignIn,
              child: Column(
                children: <Widget>[
                  GoogleSigninWidget(),
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: isLoading ? circularProgress() : Container(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: isLoading ? linearProgress() : Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> controlSignIn() async {
    preferences = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuthentication =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);

    User firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("users")
          .where("id", isEqualTo: firebaseUser.uid)
          .get();
      final List<DocumentSnapshot> documentSnapshot = resultQuery.docs;
      //Caso não possua usuário cadastrado == 0
      if (documentSnapshot.length == 0) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser.uid)
            .set({
          "id": firebaseUser.uid,
          "nickname": firebaseUser.displayName,
          "photoUrl": firebaseUser.photoURL,
          "aboutMe": "Im using Stik",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });
        //* Write local data
        currentUser = firebaseUser;
        await preferences.setString("id", currentUser.uid);
        await preferences.setString("nickname", currentUser.displayName);
        await preferences.setString("photoUrl", currentUser.photoURL);
        //*Usuário já cadastrado
      } else {
        //* Write local data
        currentUser = firebaseUser;
        await preferences.setString("id", documentSnapshot[0]["id"]);
        await preferences.setString(
            "nickname", documentSnapshot[0]["nickname"]);
        await preferences.setString(
            "photoUrl", documentSnapshot[0]["photoUrl"]);
        await preferences.setString("aboutMe", documentSnapshot[0]["aboutMe"]);
      }
      Fluttertoast.showToast(msg: "Sing In Successful.");
      this.setState(() {
        isLoading = false;
      });
      //Após signed in, mudar para próxima tela
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => LobbyView(
                    currentUserId: firebaseUser.uid,
                  )),
          (Route<dynamic> route) => false);
    } else {
      Fluttertoast.showToast(msg: "Try again.");
      this.setState(() {
        isLoading = false;
      });
    }
  }
}
