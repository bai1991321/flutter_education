import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, stdout;

import 'package:education_app/auth/auth.dart';
import 'package:education_app/buttons/simple_flat_button.dart';
import 'package:education_app/buttons/simple_round_icon_button.dart';
import 'package:education_app/facebook_sigin/facebook_sigin.dart';
import 'package:education_app/firebase_database/firebase_database.dart';
import 'package:education_app/google_signin/google_signin.dart';
import 'package:education_app/model/userModel.dart';
import 'package:education_app/ui/home_screen.dart';
import 'package:education_app/ui/login_screens/instructor_login_screen.dart';
import 'package:education_app/ui/login_screens/student_login_screen.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/image_assets.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_switch/material_switch.dart';

import '../top_logo.dart';
import 'registration_select_screen.dart';

class LoginSelectScreen extends StatefulWidget {
  final BaseAuth auth;
  final FacebookAuth facebookAuth;
  final GoogleAuth googleAuth;
  final FirebaseStorage storage;

  LoginSelectScreen(
      {Key key, this.auth, this.facebookAuth, this.googleAuth, this.storage})
      : super(key: key);

  @override
  _LoginSelectScreenState createState() => new _LoginSelectScreenState();
}

class _LoginSelectScreenState extends State<LoginSelectScreen> {
  final FacebookLogin facebookSignIn = new FacebookLogin();
  final GoogleSignIn _gSignIn = new GoogleSignIn();

  // Initialize firebase database auth with FireStore collection users table
  final FirebaseDbAuth firebaseDbAuth = new FirebaseDbAuth();

  // Initialize firebase real time database auth with FireStore collection users table
  final usersReference = FirebaseDatabase.instance.reference().child('Users');

  bool _saving = false;

  String os;
  String userId;
  String role = StringConstants.student;

  @override
  void initState() {
    super.initState();
    os = Platform.operatingSystem;
    print(os);
  }

  @override
  Widget build(BuildContext context) {
    return new Builder(
      builder: (context) => MaterialApp(
            home: Scaffold(
                body: new Builder(
                    builder: (context) => new Theme(
                        data: Theme.of(context).copyWith(
                            accentColor: const Color(AppColors.primaryColor),
                            primaryColor: const Color(AppColors.primaryColor)),
                        child: new ProgressHUD(
                            child: _buildWidgetTop(),
                            inAsyncCall: _saving,
                            opacity: 0.0)))),
          ),
    );
  }

  Widget _buildWidgetTop() {
    return new CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate([
            Column(
              children: <Widget>[
                Divider(
                  color: Colors.transparent,
                  height: 20.0,
                ),
                TopLogo(),
                Divider(
                  color: Colors.transparent,
                  height: 20.0,
                ),
                materialSwitch(),
                Divider(
                  color: Colors.transparent,
                  height: 10.0,
                ),
                _buildLoginSelectionWidget(),
              ],
            ),
          ]),
        ),
      ],
    );
  }

  Widget materialSwitch() {
    return MaterialSwitch(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
      options: StringConstants.switchOptions,
      //style: TextStyle(fontFamily: 'novaBold'),
      selectedOption: role,
      selectedBackgroundColor: const Color(AppColors.primaryColor),
      selectedTextColor: Colors.white,
      onSelect: (String selectedOption) {
        this.role = selectedOption;
        setState(() {
          selectionSwitch();
        });
      },
    );
  }

  String selectionSwitch() {
    switch (this.role) {
      case StringConstants.student:
        return role = StringConstants.student;
      case StringConstants.instructor:
        return role = StringConstants.instructor;
    }
    return role = StringConstants.student;
  }

  // Widget is for Student Login Selection
  Widget _buildLoginSelectionWidget() {
    return new Builder(
        builder: (context) => Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: new Column(
                children: <Widget>[
                  SimpleRoundIconButton(
                      backgroundColor: Colors.blueGrey,
                      buttonText: Text(
                        StringConstants.login_with_email,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'novabold',
                          fontSize: 16.0,
                        ),
                      ),
                      textColor: Colors.white,
                      icon: Icon(Icons.mail),
                      isIcon: true,
                      onPressed: () {
                        if (role == StringConstants.student) {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new StudentLogInScreen(
                                    auth: widget.auth,
                                    storage: widget.storage,
                                    facebookAuth: widget.facebookAuth,
                                    googleAuth: widget.googleAuth)),
                          );
                        } else {
                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new InstructorLogInScreen(
                                    auth: widget.auth,
                                    storage: widget.storage,
                                    facebookAuth: widget.facebookAuth,
                                    googleAuth: widget.googleAuth)),
                          );
                        }
                      }),
                  SimpleRoundIconButton(
                      backgroundColor: const Color(AppColors.googleColor),
                      buttonText: Text(
                        StringConstants.login_with_google,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'novabold',
                          fontSize: 16.0,
                        ),
                      ),
                      textColor: Colors.white,
                      isIcon: false,
                      image: new Image(
                        image: AssetImage(ImageAssets.googleLogo),
                        height: 22.0,
                        width: 22.0,
                      ),
                      onPressed: () {
                        setStateTask(true);
                        loginWithGoogle(context, _gSignIn);
                      }),
                  SimpleRoundIconButton(
                      backgroundColor: const Color(AppColors.facebookColor),
                      buttonText: Text(
                        StringConstants.login_with_facebook,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'novabold',
                          fontSize: 16.0,
                        ),
                      ),
                      textColor: Colors.white,
                      isIcon: false,
                      image: new Image(
                        image: AssetImage(ImageAssets.facebookLogo),
                        height: 22.0,
                        width: 22.0,
                      ),
                      onPressed: () {
                        setStateTask(true);
                        loginWithFacebook(context, facebookSignIn);
                      }),
                  Divider(
                    height: 40.0,
                    color: Colors.transparent,
                  ),
                  SimpleFlatButton(
                      backgroundColor: Colors.transparent,
                      buttonText: Text(
                        StringConstants.dont_have_account_text,
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'novabold',
                          fontSize: 17.0,
                        ),
                      ),
                      textColor: Colors.black,
                      onPressed: () => Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    new RegistrationSelectScreen(
                                        auth: widget.auth,
                                        facebookAuth: widget.facebookAuth,
                                        googleAuth: widget.googleAuth,
                                        storage: widget.storage)),
                          )),
                ],
              ),
            ));
  }

  void loginWithFacebook(
      BuildContext context, FacebookLogin facebookSignIn) async {
    try {
      await widget.facebookAuth
          .signIn(facebookSignIn)
          .then((FirebaseUser user) {
        print(user);
        userId = user.uid;

        usersReference.child(userId).once().then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          if (values == null) {
            addUserData(context, user.email, user.displayName, '',
                StringConstants.FACEBOOK);
          } else {
            if (values["role"] == role) {
              _setUserDataInPref(
                  values["email"],
                  values["firstName"],
                  values["lastName"],
                  values["role"],
                  values['isSignUpWith'],
                  values['signUpMethod'],
                  values['gcmId'],
                  values['handleName'],
                  values['schoolName'],
                  values['gradeLevel'],
                  values['city'],
                  values['state'],
                  values['avtarUrl'],
                  values['gender'],
                  values['difficultyLevel']);
              setStateTask(false);
              _showSnackBar(context, 'Log in Successfully');
              startTime();
            } else {
              setStateTask(false);
              _showSnackBar(context, 'Log in Failed');
            }
          }
        });
      }).catchError((e) {
        print(e);
        setStateTask(false);
        _showSnackBar(context, 'Log in Failed');
        return;
      });
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
      _showSnackBar(context, 'Log in Failed');
    }
  }

  void loginWithGoogle(BuildContext context, GoogleSignIn _gSignIn) async {
    try {
      await widget.googleAuth.signIn(_gSignIn).then((FirebaseUser user) {
        print(user);
        userId = user.uid;

        usersReference.child(userId).once().then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          if (values == null) {
            addUserData(context, user.email, user.displayName, '',
                StringConstants.GOOGLE);
          } else {
            if (values["role"] == role) {
              _setUserDataInPref(
                  values["email"],
                  values["firstName"],
                  values["lastName"],
                  values["role"],
                  values['isSignUpWith'],
                  values['signUpMethod'],
                  values['gcmId'],
                  values['handleName'],
                  values['schoolName'],
                  values['gradeLevel'],
                  values['city'],
                  values['state'],
                  values['avtarUrl'],
                  values['gender'],
                  values['difficultyLevel']);
              setStateTask(false);
              _showSnackBar(context, 'Log in Successfully');
              startTime();
            } else {
              setStateTask(false);
              _showSnackBar(context, 'Log in Failed');
            }
          }
        });
      }).catchError((e) {
        print(e);
        setStateTask(false);
        _showSnackBar(context, 'Log in Failed');
        return;
      });
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
      _showSnackBar(context, 'Log in Failed');
    }
  }

  void addUserData(BuildContext context, String _email, String _firstName,
      String _lastName, String signUpMethod) async {
    try {
      await firebaseDbAuth
          .signUpNewUser(usersReference, userId, _email, _firstName, _lastName,
              role, os, signUpMethod, '', '', '', '', '', '', '', '', '')
          .catchError((e) {
        print(e);
        setStateTask(false);
        _showSnackBar(context, 'Log in Failed');
        return;
      });
      _setUserDataInPref(_email, _firstName, _lastName, role, os, signUpMethod,
          '', '', '', '', '', '', '', '', '');
      _showSnackBar(context, 'Log in Successfully');
      setStateTask(false);
      startTime();
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
      _showSnackBar(context, 'Log in Failed');
    }
  }

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, _navigateToHomeScreen);
  }

  void _navigateToHomeScreen() {
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

  void setStateTask(isTaskDone) {
    setState(() {
      _saving = isTaskDone;
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = new SnackBar(
        content: new Text(message),
        backgroundColor: const Color(AppColors.primaryColor));

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<void> _setUserDataInPref(
      String email,
      String firstName,
      String lastName,
      String role,
      String isSignUpWith,
      String signUpMethod,
      String gcmId,
      String handleName,
      String schoolName,
      String gradeLevel,
      String city,
      String state,
      String avtarUrl,
      String gender,
      String difficultyLevel) async {
    try {
      await SharedPreferencesHelper.setUserId(userId);
      UserModel userModel = new UserModel(
          email,
          firstName,
          lastName,
          role,
          isSignUpWith,
          signUpMethod,
          gcmId,
          handleName,
          schoolName,
          gradeLevel,
          city,
          state,
          avtarUrl,
          gender,
          difficultyLevel);
      var userString = jsonEncode(userModel);
      await SharedPreferencesHelper.setUser(userString);
    } catch (e) {
      print(e);
    }
  }
}
