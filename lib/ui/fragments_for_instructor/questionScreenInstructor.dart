import 'dart:async';
import 'dart:convert';

import 'package:education_app/buttons/simple_material_button_without_padding.dart';
import 'package:education_app/firebase_database/firebase_database.dart';
import 'package:education_app/model/userModel.dart';
import 'package:education_app/textfieldsforms/simple_text_field_without_padding.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class QuestionScreenInstructor extends StatefulWidget {
  final String subjectName;
  final String catName;
  final String className;
  final int subIndex;
  final int catIndex;
  final int classIndex;

  QuestionScreenInstructor(
      {Key key,
      this.subjectName,
      this.catName,
      this.className,
      this.subIndex,
      this.catIndex,
      this.classIndex})
      : super(key: key);

  @override
  _QuestionScreenInstructorState createState() =>
      _QuestionScreenInstructorState();
}

class _QuestionScreenInstructorState extends State<QuestionScreenInstructor> {
  // Initialize firebase database auth with FireStore collection users table
  final FirebaseDbAuth firebaseDbAuth = new FirebaseDbAuth();

  // Initialize firebase real time database auth with FireStore collection users table
  final usersReference = FirebaseDatabase.instance.reference().child('Users');
  final quizQuesReference =
      FirebaseDatabase.instance.reference().child('QuizQuestion');

  final _formKeyQuestion = GlobalKey<FormState>();
  final _formKeyAnswerOne = GlobalKey<FormState>();
  final _formKeyAnswerTwo = GlobalKey<FormState>();
  final _formKeyAnswerThree = GlobalKey<FormState>();
  final _formKeyAnswerFour = GlobalKey<FormState>();

  final FocusNode _questionFocus = FocusNode();
  final FocusNode _answerOneFocus = FocusNode();
  final FocusNode _answerTwoFocus = FocusNode();
  final FocusNode _answerThreeFocus = FocusNode();
  final FocusNode _answerFourFocus = FocusNode();

  TextEditingController myQuestionController = TextEditingController();
  TextEditingController myAnswerOneController = TextEditingController();
  TextEditingController myAnswerTwoController = TextEditingController();
  TextEditingController myAnswerThreeController = TextEditingController();
  TextEditingController myAnswerFourController = TextEditingController();

  bool _autoValidate = false;
  bool _saving = false;

  bool _correctAns1 = false;
  bool _correctAns2 = false;
  bool _correctAns3 = false;
  bool _correctAns4 = false;

  String userId;
  String email;
  String name;
  String questionText;
  String answerOneText;
  String answerTwoText;
  String answerThreeText;
  String answerFourText;
  String correctAnswer;

  Map<dynamic, dynamic> values;

  //we omitted the brackets '{}' and are using fat arrow '=>' instead, this is dart syntax
  void _value1Changed(bool value) => setState(() {
        _correctAns1 = value;
        if (value = true) {
          _correctAns2 = false;
          _correctAns3 = false;
          _correctAns4 = false;
        }
      });

  void _value2Changed(bool value) => setState(() {
        _correctAns2 = value;
        if (value = true) {
          _correctAns1 = false;
          _correctAns3 = false;
          _correctAns4 = false;
        }
      });

  void _value3Changed(bool value) => setState(() {
        _correctAns3 = value;
        if (value = true) {
          _correctAns1 = false;
          _correctAns2 = false;
          _correctAns4 = false;
        }
      });

  void _value4Changed(bool value) => setState(() {
        _correctAns4 = value;
        if (value = true) {
          _correctAns1 = false;
          _correctAns2 = false;
          _correctAns3 = false;
        }
      });

  @override
  void initState() {
    super.initState();
    _getUserDataFromPref();
  }

  @override
  void dispose() {
    /// Dispose All focus fields
    _questionFocus.dispose();
    _answerOneFocus.dispose();
    _answerTwoFocus.dispose();
    _answerThreeFocus.dispose();
    _answerFourFocus.dispose();

    /// Dispose All Text Editing Controller
    myQuestionController.dispose();
    myAnswerOneController.dispose();
    myAnswerTwoController.dispose();
    myAnswerThreeController.dispose();
    myAnswerFourController.dispose();
    super.dispose();
  }

  Future<void> _getUserDataFromPref() async {
    try {
      if (await SharedPreferencesHelper.getUserId() != null) {
        userId = await SharedPreferencesHelper.getUserId();
        print(userId);
        Map userMap = jsonDecode(await SharedPreferencesHelper.getUser());
        var userModel = new UserModel.fromJson(userMap);
        if (userModel != null) {
          email = userModel.email;
          name = userModel.firstName + ' ' + userModel.lastName;
          print(email);
          print(name);
        }
      }
    } catch (e) {
      print(e);
    }
  }

//  Future<void> _userData() async {
//    try {
//      userModel = new UserModel.fromJson(userMap);
//      if(userModel != null){
//        email = userModel.email;
//        name = userModel.firstName + ' ' + userModel.lastName;
//        print(email);
//        print(name);
//      }
//
////      if (userId != null) {
////        await usersReference.child(userId).once().then((DataSnapshot snapshot) {
////          values = snapshot.value;
////          if (values != null) {
////            email = values["email"];
////            name = values["firstName"] + ' ' + values["lastName"];
////
////            print(email);
////            print(name);
////          }
////        });
////      }
//    } catch (e) {
//      print('Error: $e');
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryColor),
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(
          'Add Question',
          style: new TextStyle(fontFamily: 'novabold', color: Colors.white),
        ),
      ),
      body: new Theme(
        data: Theme.of(context).copyWith(
            accentColor: const Color(AppColors.primaryColor),
            primaryColor: const Color(AppColors.primaryColor)),
        child: new ProgressHUD(
            inAsyncCall: _saving, child: _buildWidget(), opacity: 0.0),
      ),
//      floatingActionButtonLocation:
//          MediaQuery.of(context).orientation == Orientation.portrait
//              ? FloatingActionButtonLocation.centerFloat
//              : FloatingActionButtonLocation.endFloat,
//      floatingActionButton: FloatingActionButton.extended(
//        backgroundColor: const Color(AppColors.primaryColor),
//        onPressed: () {
//          _navigateToHomePage();
//        },
//        icon: Icon(Icons.videocam),
//        label: Text(
//          StringConstants.video_tutorial,
//          style: TextStyle(
//            color: Colors.white,
//            fontFamily: 'nova',
//            fontSize: 15.0,
//          ),
//        ),
//      ),
    );
  }

  Widget _buildWidget() {
    return new Builder(
      builder: (context) => Container(
          padding: EdgeInsets.all(10.0),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  Divider(
                    height: 10.0,
                  ),
                  SimpleTextField(
                    formKey: _formKeyQuestion,
                    focusNode: _questionFocus,
                    focusNodeNext: _answerOneFocus,
                    fillColor: Colors.grey[300],
                    hintText: StringConstants.enter_question,
                    labelText: StringConstants.question_text,
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    onEditingComplete: () {},
                    textEditingController: myQuestionController,
                    validator: (value) =>
                        value.isEmpty ? 'Question can\'t be empty' : null,
                    onSaved: (value) => questionText = value,
                    autoValidate: _autoValidate,
                    maxLines: 5,
                    maxLenght: 200,
                  ),
                  Divider(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: SimpleTextField(
                          formKey: _formKeyAnswerOne,
                          focusNode: _answerOneFocus,
                          focusNodeNext: _answerTwoFocus,
                          fillColor: Colors.grey[300],
                          hintText: StringConstants.enter_option_one,
                          labelText: StringConstants.answer_one_text,
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          onEditingComplete: () {},
                          textEditingController: myAnswerOneController,
                          validator: (value) =>
                              value.isEmpty ? 'Option A can\'t be empty' : null,
                          onSaved: (value) => answerOneText = value,
                          autoValidate: _autoValidate,
                          //maxLines: 1,
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Checkbox(
                              activeColor: const Color(AppColors.primaryColor),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              value: _correctAns1,
                              onChanged: _value1Changed)),
                    ],
                  ),
                  Divider(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: SimpleTextField(
                          formKey: _formKeyAnswerTwo,
                          focusNode: _answerTwoFocus,
                          focusNodeNext: _answerThreeFocus,
                          fillColor: Colors.grey[300],
                          hintText: StringConstants.enter_option_two,
                          labelText: StringConstants.answer_two_text,
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          onEditingComplete: () {},
                          textEditingController: myAnswerTwoController,
                          validator: (value) =>
                              value.isEmpty ? 'Option B can\'t be empty' : null,
                          onSaved: (value) => answerTwoText = value,
                          autoValidate: _autoValidate,
                          //maxLines: 1,
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Checkbox(
                              activeColor: const Color(AppColors.primaryColor),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              value: _correctAns2,
                              onChanged: _value2Changed)),
                    ],
                  ),
                  Divider(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: SimpleTextField(
                          formKey: _formKeyAnswerThree,
                          focusNode: _answerThreeFocus,
                          focusNodeNext: _answerFourFocus,
                          fillColor: Colors.grey[300],
                          hintText: StringConstants.enter_option_three,
                          labelText: StringConstants.answer_three_text,
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          onEditingComplete: () {},
                          textEditingController: myAnswerThreeController,
                          validator: (value) =>
                              value.isEmpty ? 'Option C can\'t be empty' : null,
                          onSaved: (value) => answerThreeText = value,
                          autoValidate: _autoValidate,
                          //maxLines: 1,
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Checkbox(
                              activeColor: const Color(AppColors.primaryColor),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              value: _correctAns3,
                              onChanged: _value3Changed)),
                    ],
                  ),
                  Divider(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 9,
                        child: SimpleTextField(
                          formKey: _formKeyAnswerFour,
                          focusNode: _answerFourFocus,
                          focusNodeNext: null,
                          fillColor: Colors.grey[300],
                          hintText: StringConstants.enter_option_four,
                          labelText: StringConstants.answer_four_text,
                          textInputType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.none,
                          onEditingComplete: () {},
                          textEditingController: myAnswerFourController,
                          validator: (value) =>
                              value.isEmpty ? 'Option D can\'t be empty' : null,
                          onSaved: (value) => answerFourText = value,
                          autoValidate: _autoValidate,
                          //maxLines: 1,
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Checkbox(
                              activeColor: const Color(AppColors.primaryColor),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              value: _correctAns4,
                              onChanged: _value4Changed)),
                    ],
                  ),
                  Divider(
                    height: 30.0,
                  ),
                  SimpleMaterialButton(
                      backgroundColor: const Color(AppColors.primaryColor),
                      buttonText: Text(
                        StringConstants.submit_answer,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'novabold',
                          fontSize: 20.0,
                        ),
                      ),
                      textColor: Colors.white,
                      onPressed: () {
                        if (_formKeyQuestion.currentState.validate() &&
                            _formKeyAnswerOne.currentState.validate() &&
                            _formKeyAnswerTwo.currentState.validate() &&
                            _formKeyAnswerThree.currentState.validate() &&
                            _formKeyAnswerFour.currentState.validate()) {
                          if (_correctAns1 == false &&
                              _correctAns2 == false &&
                              _correctAns3 == false &&
                              _correctAns4 == false) {
                            _showSnackBar(
                                context, 'Please Choose Correct Answer');
                            return;
                          }

                          _formKeyQuestion.currentState.save();
                          _formKeyAnswerOne.currentState.save();
                          _formKeyAnswerTwo.currentState.save();
                          _formKeyAnswerThree.currentState.save();
                          _formKeyAnswerFour.currentState.save();

                          if (_correctAns1 == true) {
                            correctAnswer = answerOneText;
                          } else if (_correctAns2 == true) {
                            correctAnswer = answerTwoText;
                          } else if (_correctAns3 == true) {
                            correctAnswer = answerThreeText;
                          } else if (_correctAns4 == true) {
                            correctAnswer = answerFourText;
                          }

                          setStateTask(true);
                          quizQuestion(context);
                        } else {
                          _autoValidate = true;
                        }
                      }),
                ]),
              ),
            ],
          )),
    );
  }

  _navigateToHomePage() {
    Navigator.push(
        context,
        new MaterialPageRoute(
          maintainState: true,
          builder: (context) {
            return Container();
          },
        ));
  }

  void quizQuestion(BuildContext context) async {
    try {
      await firebaseDbAuth
          .quizQuestion(
              quizQuesReference,
              userId,
              email,
              name,
              widget.subjectName,
              widget.catName,
              widget.className,
              questionText,
              answerOneText,
              answerTwoText,
              answerThreeText,
              answerFourText,
              correctAnswer,
              "0")
          .catchError((e) {
        print(e);
        setStateTask(false);
        _showSnackBar(context, 'Question Submission Failed');
        return;
      });
      _showSnackBar(context, 'Your Question Submitted Successfully');
      clearFields();
      setStateTask(false);
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
      _showSnackBar(context, 'Question Submission Failed');
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

  void clearFields() {
    questionText = null;
    answerOneText = null;
    answerTwoText = null;
    answerThreeText = null;
    answerFourText = null;
    correctAnswer = null;
    _autoValidate = false;

    _value1Changed(false);
    _value2Changed(false);
    _value3Changed(false);
    _value4Changed(false);

    myQuestionController = TextEditingController(text: '');
    myAnswerOneController = TextEditingController(text: '');
    myAnswerTwoController = TextEditingController(text: '');
    myAnswerThreeController = TextEditingController(text: '');
    myAnswerFourController = TextEditingController(text: '');

    _questionFocus.unfocus();
    _answerOneFocus.unfocus();
    _answerTwoFocus.unfocus();
    _answerThreeFocus.unfocus();
    _answerFourFocus.unfocus();
  }
}
