import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, stdout;

import 'package:education_app/auth/auth.dart';
import 'package:education_app/buttons/simple_material_button.dart';
import 'package:education_app/facebook_sigin/facebook_sigin.dart';
import 'package:education_app/firebase_database/firebase_database.dart';
import 'package:education_app/google_signin/google_signin.dart';
import 'package:education_app/model/userModel.dart';
import 'package:education_app/textfieldsforms/simple_text_field.dart';
import 'package:education_app/ui/home_screen.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../top_logo.dart';

class InstructorSignUpScreen extends StatefulWidget {
  InstructorSignUpScreen(
      {Key key, this.auth, this.storage, this.facebookAuth, this.googleAuth})
      : super(key: key);
  final BaseAuth auth;
  final FirebaseStorage storage;
  final FacebookAuth facebookAuth;
  final GoogleAuth googleAuth;

  @override
  _InstructorSignUpScreenState createState() =>
      new _InstructorSignUpScreenState();
}

class _InstructorSignUpScreenState extends State<InstructorSignUpScreen> {
  // Initialize firebase cloud database auth with FireStore collection users table
  final FirebaseDbAuth firebaseDbAuth = new FirebaseDbAuth();

  // Initialize firebase real time database auth with FireStore collection users table
  final usersReference = FirebaseDatabase.instance.reference().child('Users');

  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  final _formKeyFirstName = GlobalKey<FormState>();
  final _formKeyLastName = GlobalKey<FormState>();

  bool _autoValidate = false;
  bool _saving = false;

  String _email; // underscore signifies that the entity is private
  String _password;
  String _firstName;
  String _lastName;
  String os;
  String userId;

  /// Initialize Focus Node for all Text Form Fields
  final FocusNode _fNameFocus = FocusNode();
  final FocusNode _lNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  /// Initialize TextEditingController for all Text Form Fields
  final myFNameController = TextEditingController();
  final myLNameController = TextEditingController();
  final myEmailController = TextEditingController();
  final myPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    os = Platform.operatingSystem;
    print(os);
  }

  @override
  void dispose() {
    /// Dispose All focus fields
    _fNameFocus.dispose();
    _lNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();

    /// Dispose All Text Editing Controller
    myFNameController.dispose();
    myLNameController.dispose();
    myEmailController.dispose();
    myPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryColor),
        centerTitle: true,
        title: new Text(
          StringConstants.signup,
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
                  formKey: _formKeyFirstName,
                  focusNode: _fNameFocus,
                  focusNodeNext: _lNameFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.firstName,
                  labelText: StringConstants.firstName,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onEditingComplete: () {},
                  textEditingController: myFNameController,
                  validator: (value) =>
                      value.isEmpty ? 'First Name can\'t be empty' : null,
                  onSaved: (value) => _firstName = value,
                  autoValidate: _autoValidate,
                ),
                SimpleTextField(
                  formKey: _formKeyLastName,
                  focusNode: _lNameFocus,
                  focusNodeNext: _emailFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.lastName,
                  labelText: StringConstants.lastName,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onEditingComplete: () {},
                  textEditingController: myLNameController,
                  validator: (value) =>
                      value.isEmpty ? 'Last Name can\'t be empty' : null,
                  onSaved: (value) => _lastName = value,
                  autoValidate: _autoValidate,
                ),
                SimpleTextField(
                  formKey: _formKeyEmail,
                  focusNode: _emailFocus,
                  focusNodeNext: _passwordFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.email,
                  labelText: StringConstants.email,
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.none,
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
                  textCapitalization: TextCapitalization.none,
                  obscureText: true,
                  onEditingComplete: () {},
                  textEditingController: myPasswordController,
                  validator: (value) =>
                      value.isEmpty ? 'Password can\'t be empty' : null,
                  onSaved: (value) => _password = value,
                  autoValidate: _autoValidate,
                ),
                SimpleMaterialButton(
                    backgroundColor: const Color(AppColors.primaryColor),
                    buttonText: Text(
                      StringConstants.signup,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'novabold',
                        fontSize: 20.0,
                      ),
                    ),
                    textColor: Colors.white,
                    onPressed: () {
                      if (_formKeyFirstName.currentState.validate() &&
                          _formKeyLastName.currentState.validate() &&
                          _formKeyEmail.currentState.validate() &&
                          _formKeyPassword.currentState.validate()) {
                        // If the form is valid, we want to show a Snackbar
                        _formKeyFirstName.currentState.save();
                        _formKeyLastName.currentState.save();
                        _formKeyEmail.currentState.save();
                        _formKeyPassword.currentState.save();

                        print(_email);
                        print(_password);
                        print(_firstName);
                        print(_lastName);
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

  void validateAndSubmit(BuildContext context) async {
    try {
      userId = await widget.auth
          .createUserWithEmailAndPassword(_email, _password)
          .catchError((e) {
        print(e);
        setStateTask(false);
        _showSnackBar(context, 'Registeration Failed');
        return;
      });
      print('Registered user: $userId');

      if (userId != null) {
        addUserData(context);
      } else {
        setStateTask(false);
      }
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
      _showSnackBar(context, 'Registeration Failed');
    }
  }

  void addUserData(BuildContext context) async {
    try {
      await firebaseDbAuth
          .signUpNewUser(
              usersReference,
              userId,
              _email,
              _firstName,
              _lastName,
              StringConstants.instructor,
              os,
              StringConstants.EMAIL,
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '')
          .catchError((e) {
        print(e);
        setStateTask(false);
        _showSnackBar(context, 'Registeration Failed');
        return;
      });
      _setUserDataInPref();
      _showSnackBar(context, 'Registered Successfully');
      setStateTask(false);
      startTime();
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
      _showSnackBar(context, 'Registeration Failed');
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

  Future<void> _setUserDataInPref() async {
    await SharedPreferencesHelper.setUserId(userId);
    UserModel userModel = new UserModel(
        _email,
        _firstName,
        _lastName,
        StringConstants.instructor,
        os,
        StringConstants.EMAIL,
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '');
    var userString = jsonEncode(userModel);
    await SharedPreferencesHelper.setUser(userString);
  }
}
