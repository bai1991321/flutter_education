import 'dart:async';
import 'dart:convert';

import 'package:education_app/google_signin/google_signin.dart';
import 'package:education_app/model/userModel.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../auth/auth.dart';
import '../facebook_sigin/facebook_sigin.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'selection_screens/login_select_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen(
      {Key key, this.auth, this.facebookAuth, this.googleAuth, this.storage})
      : super(key: key);
  final BaseAuth auth;
  final FacebookAuth facebookAuth;
  final GoogleAuth googleAuth;
  final FirebaseStorage storage;

  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

enum AuthStatus { notSignedIn, signedIn }

class _SplashScreenState extends State<SplashScreen> {
  AuthStatus _authStatus = AuthStatus.notSignedIn;

  // Initialize firebase real time database auth with FireStore collection users table
  final usersReference = FirebaseDatabase.instance.reference().child('Users');

  String userId;
  String isLogIn;
  String role;

  @override
  void initState() {
    super.initState();
    isLogInSuccess();
  }

  Future<void> isLogInSuccess() async {
    if (await SharedPreferencesHelper.getLogIn() == 'LogIn') {
      isLogIn = await SharedPreferencesHelper.getLogIn();
    }
    print(isLogIn);
    startTime();
  }

  startTime() async {
    var _duration = new Duration(seconds: 3);
    if (isLogIn == null) {
      return new Timer(_duration, _navigationPage);
    } else {
      return new Timer(_duration, _checkUserAuth);
    }
  }

  void _checkUserAuth() {
    try {
      widget.auth.currentUser().then((userId) {
        if (userId == null) {
          _authStatus = AuthStatus.notSignedIn;
          this.userId = userId;
          return _navigationPage();
        } else {
          _authStatus = AuthStatus.signedIn;
          this.userId = userId;
          return _getUserData();
        }
      });
    } catch (e) {
      print(e);
      return _navigationPage();
    }
  }

  _getUserData() async {
    try {
      await usersReference.child(userId).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          role = snapshot.value['role'];
          SharedPreferencesHelper.setUserId(userId);
          var userString = jsonEncode(UserModel.fromSnapshot(snapshot));
          SharedPreferencesHelper.setUser(userString);
          //print(userString);
          return _navigationPage();
        }
      });
    } catch (e) {
      print('Error: $e');
      return _navigationPage();
    }
  }

  void _navigationPage() {
    if (_authStatus == AuthStatus.notSignedIn) {
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
            builder: (context) => new LoginSelectScreen(
                auth: widget.auth,
                facebookAuth: widget.facebookAuth,
                googleAuth: widget.googleAuth,
                storage: widget.storage)),
      );
    } else if (_authStatus == AuthStatus.signedIn) {
      Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
            builder: (context) => new HomeScreen(
                auth: widget.auth,
                facebookAuth: widget.facebookAuth,
                googleAuth: widget.googleAuth,
                userId: userId,
                role: role,
                storage: widget.storage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: new BoxDecoration(
//            image: new DecorationImage(
//              image: new AssetImage(ImageAssets.splashBg),
//              fit: BoxFit.cover,
//            ),
            gradient: new LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              //stops: [0.1, 0.3, 0.7, 0.9],
              // 10% of the width, so there are ten blinds.
              colors: [
                const Color(AppColors.gradColorOne),
                const Color(AppColors.gradColorTwo),
                const Color(AppColors.gradColorThree),
                const Color(AppColors.gradColorOne)
              ],
              // whitish to gray
              tileMode:
                  TileMode.repeated, // repeats the gradient over the canvas
            ),
          ),
          child: new Center(
            child: new Image(
              image: AssetImage('assets/arwun_logo_full.jpg'),
              height: 200.0,
              width: 200.0,
            ),
          ),
        ),
      ),
    );
  }
}
