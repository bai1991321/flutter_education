import 'dart:async';
import 'dart:convert';

import 'package:education_app/auth/auth.dart';
import 'package:education_app/facebook_sigin/facebook_sigin.dart';
import 'package:education_app/google_signin/google_signin.dart';
import 'package:education_app/model/userModel.dart';
import 'package:education_app/ui/fragments_for_instructor/dashboardFragmentInstructor.dart';
import 'package:education_app/ui/fragments_for_instructor/homeFragmentInstructor.dart';
import 'package:education_app/ui/fragments_for_instructor/profileFragmentInstructor.dart';
import 'package:education_app/ui/fragments_for_student/homeFragmentStudent.dart';
import 'package:education_app/ui/selection_screens/login_select_screen.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class DrawersWidgetInstructor extends StatefulWidget {
  DrawersWidgetInstructor(
      {Key key,
      this.auth,
      this.facebookAuth,
      this.googleAuth,
      this.userId,
      this.storage})
      : super(key: key);
  final BaseAuth auth;
  final String userId;
  final FacebookAuth facebookAuth;
  final GoogleAuth googleAuth;
  final FirebaseStorage storage;

  final drawerItemsStudent = [
    new DrawerItem("Home", Icons.home),
    new DrawerItem("Instructor Dashboard", Icons.table_chart),
    new DrawerItem("Profile", Icons.person)
  ];

  @override
  _DrawersWidgetInstructorState createState() =>
      _DrawersWidgetInstructorState();
}

class _DrawersWidgetInstructorState extends State<DrawersWidgetInstructor> {
  final FacebookLogin facebookSignIn = new FacebookLogin();
  final GoogleSignIn _gSignIn = new GoogleSignIn();

  // Initialize firebase real time database auth with FireStore collection users table
  final usersReference = FirebaseDatabase.instance.reference().child('Users');

  int _selectedDrawerIndex = 0;

  bool _saving = true;

  String userName;
  String imageAvtar;
  BuildContext mContext;

  var userModel;

  @override
  void initState() {
    super.initState();
    _userData();
  }

  Future<void> _userData() async {
    try {
      Map userMap = jsonDecode(await SharedPreferencesHelper.getUser());
      userModel = new UserModel.fromJson(userMap);
      userName = userModel.firstName;
      _userImageAvtar();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _userImageAvtar() async {
    try {
      if (widget.userId != null) {
        await usersReference
            .child(widget.userId)
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            imageAvtar = snapshot.value["avtarUrl"];
            setStateTask(false);
          } else {
            setStateTask(false);
          }
        });
      } else {
        setStateTask(false);
      }
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
    }
  }

  _getDrawerItemWidget(BuildContext context, int pos) {
    this.mContext = context;
    switch (pos) {
      case 0:
        return new HomeFragmentInstructor();
      case 1:
        return new DashboardFragmentInstructor();
      case 2:
        return new ProfileFragmentInstructor(
            userData: _userData,
            userId: widget.userId,
            storage: widget.storage);
      default:
        return new HomeFragmentStudent();
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItemsStudent.length; i++) {
      var d = widget.drawerItemsStudent[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(
          d.icon,
          size: 25,
        ),
        title: new Text(
          d.title,
          style: getTextStyleSideMenuItems(),
        ),
        selected: i == _selectedDrawerIndex,
        contentPadding: EdgeInsets.only(left: 20.0, top: 2.0),
        onTap: () => _onSelectItem(i),
      ));
    }

    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryColor),
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(
          setAppBarTitle(),
          style: new TextStyle(fontFamily: 'novabold', color: Colors.white),
        ),
        actions: <Widget>[setLogOutIcon()],
      ),
      body: new Theme(
        data: Theme.of(context).copyWith(
            accentColor: const Color(AppColors.primaryColor),
            primaryColor: const Color(AppColors.primaryColor)),
        child: new ProgressHUD(
            inAsyncCall: _saving, child: _buildWidget(), opacity: 0.0),
      ),
      drawer: new Drawer(
          child: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: new GestureDetector(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 22.0),
                      height: 100.0,
                      width: 100.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new NetworkImage(getImageAvtar()))),
                    ),
                    new Divider(
                      height: 8.0,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        getUserName(),
                        style: getTextStyle(),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                      ),
                    )
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryColor),
              ),
            ),
            new Column(children: drawerOptions),
          ],
        ),
      )),
    );
  }

  Widget _buildWidget() {
    return new Builder(
      builder: (context) => Container(
            child: _getDrawerItemWidget(context, _selectedDrawerIndex),
          ),
    );
  }

  String setAppBarTitle() {
    return widget.drawerItemsStudent[_selectedDrawerIndex].title;
  }

  void setStateTask(isTaskDone) {
    if (this.mounted) {
      setState(() {
        _saving = isTaskDone;
      });
    }
  }

  String getImageAvtar() {
    if (imageAvtar == null) {
      return StringConstants.male_logo;
    } else if (imageAvtar == '') {
      return StringConstants.male_logo;
    } else {
      return imageAvtar;
    }
  }

  String getUserName() {
    if (userName != null) {
      return StringConstants.welcome + ' ' + this.userName;
    } else {
      return StringConstants.welcome + ' ' + StringConstants.appName;
    }
  }

  Widget setLogOutIcon() {
    if (_selectedDrawerIndex == 2) {
      return IconButton(
        icon: Icon(Icons.settings_power),
        tooltip: 'Log Out',
        onPressed: () {
          setStateTask(true);
          logOut();
        },
      );
    }

    return new Container();
  }

  void logOut() async {
    try {
      if (userModel.signUpMethod == StringConstants.EMAIL) {
      } else if (userModel.signUpMethod == StringConstants.FACEBOOK) {
        await widget.facebookAuth.signOut(facebookSignIn);
      } else if (userModel.signUpMethod == StringConstants.GOOGLE) {
        await widget.googleAuth.signOut(_gSignIn);
      }
      SharedPreferencesHelper.setLogOut(null);
      setStateTask(false);
      _showSnackBar(mContext, 'Log Out Successfully');
      startTime();
    } catch (e) {
      print(e);
    }
  }

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigateToLogInScreen);
  }

  void navigateToLogInScreen() {
    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(
          builder: (context) => new LoginSelectScreen(
              auth: widget.auth,
              facebookAuth: widget.facebookAuth,
              googleAuth: widget.googleAuth,
              storage: widget.storage)),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = new SnackBar(
        content: new Text(message),
        backgroundColor: const Color(AppColors.primaryColor));

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

TextStyle getTextStyle() {
  return new TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontSize: 15.0,
      fontFamily: 'nova');
}

TextStyle getTextStyleSideMenuItems() {
  return new TextStyle(
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
      fontSize: 16.0,
      fontFamily: 'nova');
}
