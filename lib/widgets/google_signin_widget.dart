import 'package:flutter/material.dart';

class GoogleSigninWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 250.0,
          height: 65.0,
          color: Colors.orangeAccent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                    image: AssetImage(
                      "assets/google_signin_buttons/android/xxxhdpi/btn_google_light_normal_xxxhdpi.9.png",
                    ),
                    height: 35.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
