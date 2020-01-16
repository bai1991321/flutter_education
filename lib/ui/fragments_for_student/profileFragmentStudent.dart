import 'dart:async';
import 'dart:convert';

import 'package:education_app/buttons/simple_material_button.dart';
import 'package:education_app/firebase_database/firebase_database.dart';
import 'package:education_app/model/avtar_model.dart';
import 'package:education_app/model/school_data.dart';
import 'package:education_app/model/userModel.dart';
import 'package:education_app/textfieldsforms/auto_complete_text_field.dart';
import 'package:education_app/textfieldsforms/simple_text_field.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProfileFragmentStudent extends StatefulWidget {
  final String userId;
  final FirebaseStorage storage;
  final VoidCallback userData;
  final List<SchoolData> listSchoolData;

  ProfileFragmentStudent(
      {Key key, this.userId, this.storage, this.userData, this.listSchoolData})
      : super(key: key);

  @override
  _ProfileFragmentStudentState createState() => _ProfileFragmentStudentState();
}

class _ProfileFragmentStudentState extends State<ProfileFragmentStudent>
    with WidgetsBindingObserver {
  // Initialize firebase database auth with FireStore collection users table
  final FirebaseDbAuth firebaseDbAuth = new FirebaseDbAuth();

  // Initialize firebase real time database auth with FireStore collection users table
  final usersReference = FirebaseDatabase.instance.reference().child('Users');
  final avtarMaleReference =
      FirebaseDatabase.instance.reference().child('Avtars').child('Avtar_Boys');
  final avtarFemaleReference = FirebaseDatabase.instance
      .reference()
      .child('Avtars')
      .child('Avtar_Girls');

  StreamSubscription<Event> _onAvtarSubscriptionAdded;

  final _formKeyFirstName = GlobalKey<FormState>();
  final _formKeyLastName = GlobalKey<FormState>();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyHandleName = GlobalKey<FormState>();
  final _formKeySchoolName = GlobalKey<FormState>();
  final _formKeyGradeLevel = GlobalKey<FormState>();
  final _formKeyCity = GlobalKey<FormState>();
  final _formKeyState = GlobalKey<FormState>();

  bool _autoValidate = false;

  static String _email;
  static String _firstName;
  static String _lastName;
  static String _handleName;
  static String _schoolName;
  static String _gradeLevel;
  static String _city;
  static String _state;
  String gender;
  String imageAvtar;
  String role;
  String isSignUpWith;
  String signUpMethod;
  String gcmId;
  String difficultyLevel;

  /// Initialize Focus Node for all Text Form Fields
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _handleNameFocus = FocusNode();
  final FocusNode _schoolNameFocus = FocusNode();
  final FocusNode _gradeLevelFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _stateFocus = FocusNode();

  /// Initialize TextEditingController for all Text Form Fields
  TextEditingController myEmailController = TextEditingController(text: _email);
  TextEditingController firstNameController =
      TextEditingController(text: _firstName);
  TextEditingController lastNameController =
      TextEditingController(text: _lastName);
  TextEditingController handleNameController =
      TextEditingController(text: _handleName);
  TextEditingController schoolNameController =
      TextEditingController(text: _schoolName);
  TextEditingController gradeLevelController =
      TextEditingController(text: _gradeLevel);
  TextEditingController cityController = TextEditingController(text: _city);
  TextEditingController stateController = TextEditingController(text: _state);

  bool _saving = true;

  Map<dynamic, dynamic> values;

  int pos = 1;

  List<AvtarModal> listAvtar = new List<AvtarModal>();
  List<String> listGrade = new List<String>();

  @override
  void initState() {
    super.initState();
    _loadListGrade();
    _userData();
  }

  @override
  void dispose() {
    /// Dispose All focus fields
    _emailFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _handleNameFocus.dispose();
    _schoolNameFocus.dispose();
    _gradeLevelFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();

    /// Dispose All Text Editing Controller
    myEmailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    handleNameController.dispose();
    schoolNameController.dispose();
    gradeLevelController.dispose();
    cityController.dispose();
    stateController.dispose();

    try {
      _onAvtarSubscriptionAdded.cancel();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  void _loadListGrade() {
    for (int i = 0; i < 12; i++) {
      listGrade.add('Grade 1');
      listGrade.add('Grade 2');
      listGrade.add('Grade 3');
      listGrade.add('Grade 4');
      listGrade.add('Grade 5');
      listGrade.add('Grade 6');
      listGrade.add('Grade 7');
      listGrade.add('Grade 8');
      listGrade.add('Grade 9');
      listGrade.add('Grade 10');
      listGrade.add('Grade 11');
      listGrade.add('Grade 12');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new ProgressHUD(
        inAsyncCall: _saving, child: _buildWidget(), opacity: 0.0);
  }

  Widget _buildWidget() {
    return new Builder(
      builder: (context) => Container(
            child: ListView(
              children: <Widget>[
                Divider(
                  height: 10.0,
                ),
                Center(
                    child: new GestureDetector(
                  onTap: () {
                    _showDialog();
                  },
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(getImageAvtar()))),
                  ),
                )),

                SimpleTextField(
                  formKey: _formKeyFirstName,
                  focusNode: _firstNameFocus,
                  focusNodeNext: _lastNameFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.firstName,
                  labelText: StringConstants.firstName,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onEditingComplete: () {},
                  textEditingController: firstNameController,
                  validator: (value) =>
                      value.isEmpty ? 'First Name can\'t be empty' : null,
                  onSaved: (value) => _firstName = value,
                  autoValidate: _autoValidate,
                ),

                SimpleTextField(
                  formKey: _formKeyLastName,
                  focusNode: _lastNameFocus,
                  focusNodeNext: _handleNameFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.lastName,
                  labelText: StringConstants.lastName,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onEditingComplete: () {},
                  textEditingController: lastNameController,
                  validator: (value) =>
                      value.isEmpty ? 'Last Name can\'t be empty' : null,
                  onSaved: (value) => _lastName = value,
                  autoValidate: _autoValidate,
                ),

                SimpleTextField(
                  formKey: _formKeyEmail,
                  focusNode: null,
                  focusNodeNext: null,
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
                  enabled: false,
                ),

                SimpleTextField(
                  formKey: _formKeyHandleName,
                  focusNode: _handleNameFocus,
                  focusNodeNext: _schoolNameFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.handleName,
                  labelText: StringConstants.handleName,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {},
                  textEditingController: handleNameController,
                  validator: (value) =>
                      value.isEmpty ? 'Handle Name can\'t be empty' : null,
                  onSaved: (value) => _handleName = value,
                  autoValidate: _autoValidate,
                ),

                SimpleAutoCompleteTextFormField(
                  formKey: _formKeySchoolName,
                  focusNode: _schoolNameFocus,
                  focusNodeNext: _gradeLevelFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.schoolName,
                  labelText: StringConstants.schoolName,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {},
                  textEditingController: schoolNameController,
                  validator: (value) =>
                      value.isEmpty ? 'School Name can\'t be empty' : null,
                  onSaved: (value) => _schoolName = value,
                  autoValidate: _autoValidate,
                  suggestionsCallback: (pattern) {
                    return SchoolData.getSuggestions(
                        widget.listSchoolData, pattern);
                  },
                  onSuggestionSelected: (suggestion) {
                    schoolNameController.text = suggestion;
                    compareSchoolName(suggestion);
                  },
                ),

//                SimpleTextField(
//                  formKey: _formKeySchoolName,
//                  focusNode: _schoolNameFocus,
//                  focusNodeNext: _gradeLevelFocus,
//                  fillColor: Colors.grey[300],
//                  hintText: StringConstants.schoolName,
//                  labelText: StringConstants.schoolName,
//                  textInputType: TextInputType.text,
//                  textInputAction: TextInputAction.done,
//                  onEditingComplete: () {},
//                  textEditingController: schoolNameController,
//                  validator: (value) =>
//                      value.isEmpty ? 'School Name can\'t be empty' : null,
//                  onSaved: (value) => _schoolName = value,
//                  autoValidate: _autoValidate,
//                ),

                SimpleAutoCompleteTextFormField(
                  formKey: _formKeyGradeLevel,
                  focusNode: _gradeLevelFocus,
                  focusNodeNext: _cityFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.gradeLevel,
                  labelText: StringConstants.gradeLevel,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {},
                  textEditingController: gradeLevelController,
                  validator: (value) =>
                      value.isEmpty ? 'Grade Level can\'t be empty' : null,
                  onSaved: (value) => _gradeLevel = value,
                  autoValidate: _autoValidate,
                  suggestionsCallback: (pattern) {
                    return SchoolData.getFilterGrade(listGrade, pattern);
                  },
                  onSuggestionSelected: (suggestion) {
                    gradeLevelController.text = suggestion;
                  },
                ),

//                SimpleTextField(
//                  formKey: _formKeyGradeLevel,
//                  focusNode: _gradeLevelFocus,
//                  focusNodeNext: _cityFocus,
//                  fillColor: Colors.grey[300],
//                  hintText: StringConstants.gradeLevel,
//                  labelText: StringConstants.gradeLevel,
//                  textInputType: TextInputType.text,
//                  textInputAction: TextInputAction.next,
//                  onEditingComplete: () {},
//                  textEditingController: gradeLevelController,
//                  validator: (value) =>
//                      value.isEmpty ? 'Grade Level can\'t be empty' : null,
//                  onSaved: (value) => _gradeLevel = value,
//                  autoValidate: _autoValidate,
//                ),

                SimpleTextField(
                  formKey: _formKeyCity,
                  focusNode: _cityFocus,
                  focusNodeNext: _stateFocus,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.city,
                  labelText: StringConstants.city,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {},
                  textEditingController: cityController,
                  validator: (value) =>
                      value.isEmpty ? 'City can\'t be empty' : null,
                  onSaved: (value) => _city = value,
                  autoValidate: _autoValidate,
                ),

                SimpleTextField(
                  formKey: _formKeyState,
                  focusNode: _stateFocus,
                  focusNodeNext: null,
                  fillColor: Colors.grey[300],
                  hintText: StringConstants.state,
                  labelText: StringConstants.state,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {},
                  textEditingController: stateController,
                  validator: (value) =>
                      value.isEmpty ? 'State can\'t be empty' : null,
                  onSaved: (value) => _state = value,
                  autoValidate: _autoValidate,
                ),

                //rememberMe(),
                SimpleMaterialButton(
                    backgroundColor: const Color(AppColors.primaryColor),
                    buttonText: Text(
                      StringConstants.submit_caps,
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
                          _formKeyHandleName.currentState.validate() &&
                          _formKeySchoolName.currentState.validate() &&
                          _formKeyGradeLevel.currentState.validate() &&
                          _formKeyCity.currentState.validate() &&
                          _formKeyState.currentState.validate()) {
                        // If the form is valid, we want to show a Snackbar

                        if (!listGrade.contains(gradeLevelController.text)) {
                          _showSnackBar(
                              context, 'Please select Grade Level from List');
                          _autoValidate = true;
                          return;
                        }

                        _formKeyFirstName.currentState.save();
                        _formKeyLastName.currentState.save();
                        _formKeyEmail.currentState.save();
                        _formKeyHandleName.currentState.save();
                        _formKeySchoolName.currentState.save();
                        _formKeyGradeLevel.currentState.save();
                        _formKeyCity.currentState.save();
                        _formKeyState.currentState.save();

                        if (_gradeLevel.contains('Grade')) {
                          difficultyLevel =
                              _gradeLevel.replaceFirst('Grade', '').trim() +
                                  '.00';
                        } else {
                          difficultyLevel = '';
                        }

                        print(widget.userId);
                        print(_email);
                        print(_firstName);
                        print(_lastName);
                        print(_handleName);
                        print(_schoolName);
                        print(_gradeLevel);
                        print(_city);
                        print(_state);
                        print(gender);
                        print(imageAvtar);
                        print(difficultyLevel);

                        setStateTask(true);
                        updateUserData(context);
                      } else {
                        _autoValidate = true;
                      }
                    }),
                Divider(
                  height: 10.0,
                ),
              ],
            ),
          ),
    );
  }

  void compareSchoolName(String suggestion) async {
    try {
      for (int i = 0; i < widget.listSchoolData.length; i++) {
        SchoolData schoolData = widget.listSchoolData[i];
        if (schoolData.schoolName == suggestion) {
          print(schoolData.state);
          print(schoolData.city);
          _city = schoolData.city;
          _state = schoolData.state;
          cityController = TextEditingController(text: _city);
          stateController = TextEditingController(text: _state);
          setState(() {});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _userData() async {
    try {
      if (widget.userId != null) {
        await usersReference
            .child(widget.userId)
            .once()
            .then((DataSnapshot snapshot) {
          values = snapshot.value;
          if (values != null) {
            _email = values["email"];
            _firstName = values["firstName"];
            _lastName = values["lastName"];
            role = values["role"];
            isSignUpWith = values["isSignUpWith"];
            signUpMethod = values["signUpMethod"];
            gcmId = values["gcmId"];
            _handleName = values["handleName"];
            _schoolName = values["schoolName"];
            _gradeLevel = values["gradeLevel"];
            _city = values["city"];
            _state = values["state"];
            gender = values["gender"];
            imageAvtar = values["avtarUrl"];
            difficultyLevel = values["difficultyLevel"];

            myEmailController = TextEditingController(text: _email);
            firstNameController = TextEditingController(text: _firstName);
            lastNameController = TextEditingController(text: _lastName);
            handleNameController = TextEditingController(text: _handleName);
            schoolNameController = TextEditingController(text: _schoolName);
            gradeLevelController = TextEditingController(text: _gradeLevel);
            cityController = TextEditingController(text: _city);
            stateController = TextEditingController(text: _state);

            setUserDataInPref();

            print(_email);
            print(_firstName);
            print(_lastName);
            print(role);
            print(isSignUpWith);
            print(signUpMethod);
            print(gcmId);
            print(_handleName);
            print(_schoolName);
            print(_gradeLevel);
            print(_city);
            print(_state);
            print(gender);
            print(imageAvtar);
            print(difficultyLevel);

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

  String getImageAvtar() {
    if (imageAvtar == null) {
      return StringConstants.male_logo;
    } else if (imageAvtar == '') {
      return StringConstants.male_logo;
    } else {
      return imageAvtar;
    }
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

  // user defined function
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Choose gender",
            style: getTextStyle(),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Male", style: getTextStyleGender()),
              onPressed: () {
                Navigator.of(context).pop();
                if (listAvtar != null) {
                  listAvtar.clear();
                }
                setStateTask(true);
                gender = 'Male';
                _gettingAvtarResponse(gender);
              },
            ),

            new FlatButton(
              child: new Text("Female", style: getTextStyleGender()),
              onPressed: () {
                Navigator.of(context).pop();
                if (listAvtar != null) {
                  listAvtar.clear();
                }
                setStateTask(true);
                gender = 'Female';
                _gettingAvtarResponse(gender);
              },
            ),
          ],
        );
      },
    );
  }

  void _gettingAvtarResponse(String gender) async {
    if (gender == 'Male') {
      _onAvtarSubscriptionAdded =
          avtarMaleReference.onChildAdded.listen(_onAvtarAdded);
    } else {
      _onAvtarSubscriptionAdded =
          avtarFemaleReference.onChildAdded.listen(_onAvtarAdded);
    }
  }

  void _onAvtarAdded(Event event) {
    setState(() {
      listAvtar.add(new AvtarModal.fromSnapshot(event.snapshot));
    });

    if (listAvtar.length == 5) {
      setStateTask(false);
      _showAvtarDialogWidget();
    }
  }

  void _showAvtarDialogWidget() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10.0),
          title: new Text(
            "Choose Avtar",
            style: getTextStyle(),
          ),
          content: new Container(
              width: MediaQuery.of(context).size.width * .7,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        // To convert this infinite list to a list with three items,
                        // uncomment the following line:
                        // if (index > 3) return null;
                        return getBody(index, context);
                      },
                      // Or, uncomment the following line:
                      childCount: listAvtar.length,
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }

  Widget getBody(int i, BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          child: new GestureDetector(
            onTap: () {
              imageAvtar = listAvtar[i].url;
              setState(() {
                Navigator.of(context).pop();
              });
            },
            child: Row(
              children: <Widget>[
                Container(
                  height: 100.0,
                  width: 100.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage("${listAvtar[i].url}"))),
                ),
              ],
            ),
          ),
        ));
  }

  void updateUserData(BuildContext context) async {
    try {
      await firebaseDbAuth
          .signUpNewUser(
              usersReference,
              widget.userId,
              _email,
              _firstName,
              _lastName,
              role,
              isSignUpWith,
              signUpMethod,
              gcmId,
              _handleName,
              _schoolName,
              _gradeLevel,
              _city,
              _state,
              imageAvtar,
              gender,
              difficultyLevel)
          .catchError((e) {
        print(e);
        setStateTask(false);
        _showSnackBar(context, 'Update Failed');
        return;
      });
      setUserDataInPref();
      _showSnackBar(context, 'Update Successfully');
      setStateTask(false);
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
      _showSnackBar(context, 'Update Failed');
    }
  }

  TextStyle getTextStyle() {
    return new TextStyle(
        fontWeight: FontWeight.normal,
        color: Colors.black,
        fontSize: 18.0,
        fontFamily: 'nova-bold');
  }

  TextStyle getTextStyleGender() {
    return new TextStyle(
        fontWeight: FontWeight.normal,
        color: const Color(AppColors.primaryColor),
        fontSize: 16.0,
        fontFamily: 'nova-bold');
  }

  Future<void> setUserDataInPref() async {
    await SharedPreferencesHelper.setUserId(widget.userId);
    UserModel userModel = new UserModel(
        _email,
        _firstName,
        _lastName,
        role,
        isSignUpWith,
        signUpMethod,
        gcmId,
        _handleName,
        _schoolName,
        _gradeLevel,
        _city,
        _state,
        imageAvtar,
        gender,
        difficultyLevel);
    var userString = jsonEncode(userModel);
    await SharedPreferencesHelper.setUser(userString);
    widget.userData();
  }
}
