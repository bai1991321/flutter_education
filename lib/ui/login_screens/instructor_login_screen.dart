import 'dart:async';
import 'dart:convert';

import 'package:education_app/auth/auth.dart';
import 'package:education_app/buttons/simple_material_button.dart';
import 'package:education_app/facebook_sigin/facebook_sigin.dart';
import 'package:education_app/google_signin/google_signin.dart';
import 'package:education_app/model/userModel.dart';
import 'package:education_app/textfieldsforms/simple_text_field.dart';
import 'package:education_app/textfieldsforms/simple_text_view.dart';
import 'package:education_app/ui/home_screen.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../top_logo.dart';

class InstructorLogInScreen extends StatefulWidget {
  final BaseAuth auth;
  final FirebaseStorage storage;
  final FacebookAuth facebookAuth;
  final GoogleAuth googleAuth;

  InstructorLogInScreen(
      {Key key, this.auth, this.storage, this.facebookAuth, this.googleAuth})
      : super(key: key);

  @override
  _InstructorLogInScreenState createState() =>
      new _InstructorLogInScreenState();
}

class _InstructorLogInScreenState extends State<InstructorLogInScreen> {
  // Initialize firebase real time database auth with FireStore collection users table
  final usersReference = FirebaseDatabase.instance.reference().child('Users');

  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  bool _autoValidate = false;

  String _email; // underscore signifies that the entity is private
  String _password;
  String userId;

  /// Initialize Focus Node for all Text Form Fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  /// Initialize TextEditingController for all Text Form Fields
  final myEmailController = TextEditingController();
  final myPasswordController = TextEditingController();

  bool _value1 = false;
  bool _saving = false;

  void _value1Changed(bool value) => setState(() => _value1 = value);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    /// Dispose All focus fields
    _emailFocus.dispose();
    _passwordFocus.dispose();

    /// Dispose All Text Editing Controller
    myEmailController.dispose();
    myPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryColor),
        centerTitle: true,
        title: new Text(
          StringConstants.login,
          style: new TextStyle(fontFamily: 'nova-bold'),
        ),
      ),
      body: new Theme(
        data: Theme.of(context).copyWith(
            accentColor: const Color(AppColors.primaryColor),
            primaryColor: const Color(AppColors.primaryColor)),
        child: new ProgressHUD(
            inAsyncCall: _saving, child: _buildWidget(), opacity: 0.0),
      ),
    );
  }

  Widget _buildWidget() {
    return new Builder(
      builder: (context) => Container(
            child: ListView(
              children: <Widget>[
                TopLogo(),
                SimpleTextField(
                  formKey: _formKeyEmail,
                  focusNode: _emailFocus,
                  focusNodeNext: _passwordFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.email,
                  labelText: StringConstants.email,
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {},
                  textEditingController: myEmailController,
                  validator: validateEmail,
                  onSaved: (value) => _email = value,
                  autoValidate: _autoValidate,
                ),
                SimpleTextField(
                  formKey: _formKeyPassword,
                  focusNode: _passwordFocus,
                  focusNodeNext: null,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.password,
                  labelText: StringConstants.password,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  onEditingComplete: () {},
                  textEditingController: myPasswordController,
                  validator: (value) =>
                      value.isEmpty ? 'Password can\'t be empty' : null,
                  onSaved: (value) => _password = value,
                  autoValidate: _autoValidate,
                ),
                //rememberMe(),
                SimpleMaterialButton(
                    backgroundColor: const Color(AppColors.primaryColor),
                    buttonText: Text(
                      StringConstants.login,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'novabold',
                        fontSize: 20.0,
                      ),
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      if (_formKeyEmail.currentState.validate() &&
                          _formKeyPassword.currentState.validate()) {
                        // If the form is valid, we want to show a Snackbar
                        _formKeyEmail.currentState.save();
                        _formKeyPassword.currentState.save();

                        print(_email);
                        print(_password);

                        setStateTask(true);
                        validateAndSubmit(context);
                      } else {
                        _autoValidate = true;
                      }
                    }),
              ],
            ),
          ),
    );
  }

  Widget rememberMe() {
    return new Container(
        padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
        child: new Row(
          children: <Widget>[
            Checkbox(
              activeColor: const Color(AppColors.primaryColor),
              value: _value1,
              onChanged: _value1Changed,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            SimpleTextView(
              data: StringConstants.rememberMe,
              color: Colors.black,
              fontSize: 15.0,
              fontWeight: FontWeight.normal,
            ),
          ],
        ));
  }

  void validateAndSubmit(BuildContext context) async {
    try {
      userId = await widget.auth
          .signInWithEmailAndPassword(_email, _password)
          .catchError((e) => print(e));
      print('SignIn user: $userId');

      await usersReference.child(userId).once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        if (values["role"] == StringConstants.instructor) {
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
              values['gender'], values['difficultyLevel']);
          setStateTask(false);
          _showSnackBar(context, 'Log in Successfully');
          startTime();
        } else {
          setStateTask(false);
          _showSnackBar(context, 'Log in Failed');
        }
      });
    } catch (e) {
      print('Error: $e');
      //_showSnackBar(context, e.toString());
      setStateTask(false);
      _showSnackBar(context, 'Log in Failed');
    }
  }

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigateToHomeScreen);
  }

  void navigateToHomeScreen() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(
          builder: (context) => new HomeScreen(
              auth: widget.auth,
              userId: userId,
              storage: widget.storage,
              facebookAuth: widget.facebookAuth,
              googleAuth: widget.googleAuth,
              role: StringConstants.instructor)),
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

  String validateMobile(String value) {
    // Indian Mobile number are of 10 digit only
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
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
      String gender, String difficultyLevel) async {
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
        gender, difficultyLevel);
    var userString = jsonEncode(userModel);
    await SharedPreferencesHelper.setUser(userString);
  }
}
