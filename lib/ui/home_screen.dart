import 'package:education_app/auth/auth.dart';
import 'package:education_app/facebook_sigin/facebook_sigin.dart';
import 'package:education_app/google_signin/google_signin.dart';
import 'package:education_app/ui/drawer_widgets/drawer_widget_instructor.dart';
import 'package:education_app/ui/drawer_widgets/drawer_widget_student.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../utils/string_constants.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(
      {Key key,
      this.auth,
      this.facebookAuth,
      this.googleAuth,
      this.userId,
      this.storage,
      this.role})
      : super(key: key);
  final BaseAuth auth;
  final String userId;
  final FacebookAuth facebookAuth;
  final GoogleAuth googleAuth;
  final FirebaseStorage storage;
  final String role;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userModel;

  @override
  void initState() {
    super.initState();
    _setLogInPref();
  }

  Future<void> _setLogInPref() async {
    await SharedPreferencesHelper.setLogIn('LogIn');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Theme(
        data: Theme.of(context).copyWith(
            accentColor: const Color(AppColors.primaryColor),
            primaryColor: const Color(AppColors.primaryColor)),
        child: _setDrawerWidget(),
      ),
    );
  }

  Widget _setDrawerWidget() {
    if (widget.role != null) {
      if (widget.role == StringConstants.student) {
        print('<<Role For S>>'+widget.role);
        return new DrawersWidgetStudent(
            auth: widget.auth,
            facebookAuth: widget.facebookAuth,
            googleAuth: widget.googleAuth,
            userId: widget.userId,
            storage: widget.storage);
      } else {
        print('<<Role For I>>'+widget.role);
        return new DrawersWidgetInstructor(
            auth: widget.auth,
            facebookAuth: widget.facebookAuth,
            googleAuth: widget.googleAuth,
            userId: widget.userId,
            storage: widget.storage);
      }
    }
    return new DrawersWidgetStudent();
  }

  TextStyle getTextStyleSideMenuItems() {
    return new TextStyle(
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      fontSize: 16.0,
    );
  }
}
