import 'dart:async';
import 'dart:convert';

import 'package:education_app/buttons/simple_material_button_without_padding.dart';
import 'package:education_app/firebase_database/firebase_database.dart';
import 'package:education_app/model/ansModel.dart';
import 'package:education_app/model/quizModel.dart';
import 'package:education_app/model/userModel.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class QuizScreenStudent extends StatefulWidget {
  final String subjectName;
  final String catName;
  final VoidCallback closeCatWidget;

  QuizScreenStudent(
      {Key key, this.subjectName, this.catName, this.closeCatWidget})
      : super(key: key);

  @override
  _QuizScreenStudentState createState() => _QuizScreenStudentState();
}

class _QuizScreenStudentState extends State<QuizScreenStudent> {
  // Initialize firebase database auth with FireStore collection users table
  final FirebaseDbAuth firebaseDbAuth = new FirebaseDbAuth();

  // Initialize firebase real time database auth with FireStore collection users table
  final usersReference = FirebaseDatabase.instance.reference().child('Users');

  final quizAnsReference =
      FirebaseDatabase.instance.reference().child('QuizAnswer');

  final studentLearningRateReference =
      FirebaseDatabase.instance.reference().child('StudentLearningRate');

  bool _saving = true;
  bool _isGradeExits = true;

  String userId;
  String grade;
  String email;
  String name;
  String difficultyLevel;
  String question = '';
  String answerOne = '';
  String answerTwo = '';
  String answerThree = '';
  String answerFour = '';
  String answerText;

  int score = 0;
  int learningRate = 0;
  int session = 0;

  StreamSubscription<Event> _matchSubscription;
  StreamSubscription<Event> _quizSubscription;

  List<QuizModel> quizList;
  List<AnsModel> ansList;

  Map<dynamic, dynamic> _valuesQuiz;
  Map<dynamic, dynamic> _valuesMatch;

  var userModel;

  var colorAnsOne = Colors.white;
  var colorAnsTwo = Colors.white;
  var colorAnsThree = Colors.white;
  var colorAnsFour = Colors.white;

  bool isQuestionSelect = false;
  bool isMatch = false;
  bool skipNext10Step = false;

  int pos = 0;

  BuildContext context;

  int limitFirstMatch = 1000;
  int limitFirstQuiz = 10;

  String startPosMatch = '0';
  String endPosMatch = '999';
  String startPosQuiz = '0';
  String endPosQuiz = '9';

  _QuizScreenStudentState();

  @override
  void initState() {
    super.initState();
    quizList = new List();
    ansList = new List();
    _getUserDataFromPref();
  }

  @override
  void dispose() {
    try {
      _quizSubscription.cancel();
      _matchSubscription.cancel();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  Future<void> _getUserDataFromPref() async {
    try {
      if (await SharedPreferencesHelper.getUserId() != null) {
        userId = await SharedPreferencesHelper.getUserId();
        session = await SharedPreferencesHelper.getSession();
        if (session == null) {
          session = 0;
        }
        print(userId);
        print('<<session>>' + session.toString());
        Map userMap = jsonDecode(await SharedPreferencesHelper.getUser());
        userModel = new UserModel.fromJson(userMap);
        if (userModel != null) {
          email = userModel.email;
          name = userModel.firstName + ' ' + userModel.lastName;
          grade = userModel.gradeLevel;
          difficultyLevel = userModel.difficultyLevel;
          print(email);
          print(name);
          print(grade);
          print(difficultyLevel);
        }

        checkIfGradeExists(grade);
      }
    } catch (e) {
      print(e);
    }
  }

  // Check If Grade Exists on Database Or Not
  Future<void> checkIfGradeExists(mGrade) async {
    FirebaseDatabase.instance
        .reference()
        .child('MasterQuestion')
        .child(mGrade)
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        print('true');
        // Check category are null or not
//        if (widget.catName != null && widget.catName != '') {
//          _matchWithGradeLevel();
//        } else {
//          print('Anything Goes');
//          _isGradeExits = true;
//          _matchWithGradeLevel();
//        }
        _matchWithGradeLevel();
      } else {
        print('false');
        if (mGrade.contains('Grade')) {
          int incGrade = int.parse(mGrade.replaceFirst('Grade', '').trim()) + 1;
          if (incGrade > 12) {
            _isGradeExits = false;
            setStateTask(false);
            print(incGrade);
            return;
          }
          grade = 'Grade ' + incGrade.toString();
          checkIfGradeExists(grade);
        }
      }
    });
  }

  void _matchWithGradeLevel() {
    if (grade == 'Grade 1' && difficultyLevel == '1.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 2' && difficultyLevel == '2.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 3' && difficultyLevel == '3.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 4' && difficultyLevel == '4.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 5' && difficultyLevel == '5.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 6' && difficultyLevel == '6.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 7' && difficultyLevel == '7.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 8' && difficultyLevel == '8.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 9' && difficultyLevel == '9.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 10' && difficultyLevel == '10.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 11' && difficultyLevel == '11.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else if (grade == 'Grade 12' && difficultyLevel == '12.00') {
      _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
    } else {
      _matchWithDifficultyLevel(limitFirstMatch, startPosMatch, endPosMatch);
    }
  }

  Future<void> _matchWithDifficultyLevel(
      int limitFirst, String startPos, String endPos) async {
    var matchDiffReference;
    if (widget.catName != null && widget.catName != '') {
      matchDiffReference = FirebaseDatabase.instance
          .reference()
          .child('MasterQuestion')
          .child(grade)
          .child(widget.subjectName)
          .child(widget.catName)
          .startAt(startPos)
          .endAt(endPos)
          .limitToFirst(limitFirst)
          .orderByKey();
    } else {
      matchDiffReference = FirebaseDatabase.instance
          .reference()
          .child('MasterQuestion')
          .child(grade)
          .child(widget.subjectName)
          .child('AnythingGoes')
          .startAt(startPos)
          .endAt(endPos)
          .limitToFirst(limitFirst)
          .orderByKey();
    }

    _matchSubscription = matchDiffReference.onChildAdded.listen((Event event) {
      _valuesMatch = event.snapshot.value;
      //print('<<Difficulty>>' + _valuesMatch['difficulty']);
      print('KeyTop>>' + event.snapshot.key);

      if (_valuesMatch != null) {
        double val = double.parse(_valuesMatch['difficulty']);
        double val2 = double.parse(difficultyLevel);

        if (val > val2) {
          isMatch = true;
          print('<<Match Position>>' + event.snapshot.key);
          print('<<Diff Value>>' + _valuesMatch['difficulty']);

          if (skipNext10Step) {
            //session = ((int.parse(event.snapshot.key) + 1) ~/ 10) + 1;
            //print('<<session>>' + session.toString());
            startPosQuiz = (int.parse(event.snapshot.key) + 10).toString();
            print('<<startPosQuiz>>' + startPosQuiz);
            endPosQuiz = (int.parse(startPosQuiz) + 9).toString();
            print('<<endPosQuiz>>' + endPosQuiz);
            skipNext10Step = false;
          } else {
            //session = ((int.parse(event.snapshot.key) + 1) ~/ 10) + 1;
            //print('<<session>>' + session.toString());
            startPosQuiz = (int.parse(event.snapshot.key)).toString();
            endPosQuiz = (int.parse(startPosQuiz) + 9).toString();
          }

          _matchSubscription.cancel();
          _quizList(limitFirstQuiz, startPosQuiz, endPosQuiz);
          return;
        }

        if (endPos == event.snapshot.key) {
          _isGradeExits = false;
          setStateTask(false);
        }
      } else {
        print('Here Match');
        _isGradeExits = false;
        setStateTask(false);
      }
    }, onError: (Object o) {
      final DatabaseError error = o;
      print('Error: ${error.code} ${error.message}');
      setStateTask(false);
    });
  }

  Future<void> _quizList(int limitFirst, String startPos, String endPos) async {
    var quizQuesReference;
    if (widget.catName != null && widget.catName != '') {
      quizQuesReference = FirebaseDatabase.instance
          .reference()
          .child('MasterQuestion')
          .child(grade)
          .child(widget.subjectName)
          .child(widget.catName)
          .startAt(startPos)
          .endAt(endPos)
          .limitToFirst(limitFirst)
          .orderByKey();
    } else {
      quizQuesReference = FirebaseDatabase.instance
          .reference()
          .child('MasterQuestion')
          .child(grade)
          .child(widget.subjectName)
          .child('AnythingGoes')
          .startAt(startPos)
          .endAt(endPos)
          .limitToFirst(limitFirst)
          .orderByKey();
    }

    _quizSubscription = quizQuesReference.onChildAdded.listen((Event event) {
      _valuesQuiz = event.snapshot.value;
      if (_valuesQuiz != null) {
        _setQuizQuestion(event.snapshot.key);
      } else {
        print('Here Quiz');
        _isGradeExits = false;
        setStateTask(false);
      }
    }, onError: (Object o) {
      final DatabaseError error = o;
      print('Error: ${error.code} ${error.message}');
      setStateTask(false);
    });
  }

  void handleDoneQuiz() {
    if (quizList.length == 10) {
      setStateTask(false);
      print('Quiz List Full With 10 Quiz Questions');
    }
  }

  void _setQuizQuestion(String pos) {
    QuizModel quizModel = new QuizModel(
        pos,
        _valuesQuiz["name"],
        _valuesQuiz["Grade"],
        _valuesQuiz["subject"],
        _valuesQuiz["question"],
        _valuesQuiz["category"],
        _valuesQuiz["answerOne"],
        _valuesQuiz["answerTwo"],
        _valuesQuiz["answerThree"],
        _valuesQuiz["answerFour"],
        _valuesQuiz["correctAnswer"],
        _valuesQuiz["difficulty"],
        _valuesQuiz["priority"]);
    quizList.add(quizModel);
    print('QuizList>>' + quizList.length.toString());
    handleDoneQuiz();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: const Color(AppColors.primaryColor),
        centerTitle: true,
        iconTheme: new IconThemeData(color: Colors.white),
        title: new Text(
          widget.subjectName + ' Quiz',
          style: new TextStyle(fontFamily: 'nova-bold', color: Colors.white),
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
    if (!_isGradeExits) {
      return _noResultWidget();
    } else if (quizList.length == 0) {
      return new Container();
    } else if (quizList.length >= 0) {
      return new Builder(
        builder: (context) => Container(
            padding: EdgeInsets.all(10.0),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _questionWidget(question = quizList[pos].question),
                      _answerWidgetOne(
                          answerOne = quizList[pos].answerOne, colorAnsOne),
                      _answerWidgetTwo(
                          answerTwo = quizList[pos].answerTwo, colorAnsTwo),
                      _answerWidgetThree(
                          answerThree = quizList[pos].answerThree,
                          colorAnsThree),
                      _answerWidgetFour(
                          answerFour = quizList[pos].answerFour, colorAnsFour),
                      Divider(
                        height: 20.0,
                      ),
                      _submitButtonWidget(isQuestionSelect, context),
                    ],
                  ),
                ),
              ],
            )),
      );
    }
    return new Container();
  }

  Widget _noResultWidget() {
    return Center(
      child: Text(
        'Quiz not available',
        style: getTextStyle(),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _questionWidget(String text) {
    return Container(
      height: 150.0,
      width: double.infinity,
//        child: Card(
//          shape: Border.all(
//            color: Colors.white,
//            width: 1.5,
//            style: BorderStyle.solid,
//          ),
      child: Container(
        padding: EdgeInsets.all(15.0),
        child: Text(
          text,
          maxLines: 7,
          style: getTextStyle(),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  Widget _answerWidgetOne(String text, Color color) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          colorAnsOne = Colors.green;
          colorAnsTwo = Colors.white;
          colorAnsThree = Colors.white;
          colorAnsFour = Colors.white;
          isQuestionSelect = true;
          answerText = text;
          setState(() {});
        },
        child: Card(
          shape: Border.all(
            color: color,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    'A.',
                    style: getTextStyle(),
                    textAlign: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    text,
                    style: getTextStyle(),
                    textAlign: TextAlign.start,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerWidgetTwo(String text, Color color) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          colorAnsOne = Colors.white;
          colorAnsTwo = Colors.green;
          colorAnsThree = Colors.white;
          colorAnsFour = Colors.white;
          isQuestionSelect = true;
          answerText = text;
          setState(() {});
        },
        child: Card(
          shape: Border.all(
            color: color,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    'B.',
                    style: getTextStyle(),
                    textAlign: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    text,
                    style: getTextStyle(),
                    textAlign: TextAlign.start,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerWidgetThree(String text, Color color) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          colorAnsOne = Colors.white;
          colorAnsTwo = Colors.white;
          colorAnsThree = Colors.green;
          colorAnsFour = Colors.white;
          isQuestionSelect = true;
          answerText = text;
          setState(() {});
        },
        child: Card(
          shape: Border.all(
            color: color,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    'C.',
                    style: getTextStyle(),
                    textAlign: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    text,
                    style: getTextStyle(),
                    textAlign: TextAlign.start,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerWidgetFour(String text, Color color) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          colorAnsOne = Colors.white;
          colorAnsTwo = Colors.white;
          colorAnsThree = Colors.white;
          colorAnsFour = Colors.green;
          isQuestionSelect = true;
          answerText = text;
          setState(() {});
        },
        child: Card(
          shape: Border.all(
            color: color,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          child: Container(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(
                    'D.',
                    style: getTextStyle(),
                    textAlign: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    text,
                    style: getTextStyle(),
                    textAlign: TextAlign.start,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitButtonWidget(bool isQuestionSelect, BuildContext context) {
    if (isQuestionSelect) {
      return Container(
        padding: EdgeInsets.all(4.0),
        child: SimpleMaterialButton(
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
              if (answerText == quizList[pos].correctAnswer) {
                score++;
                _showSnackBar(
                    context, 'Correct Answer', Colors.green, false, 2);
              } else {
                _showSnackBar(
                    context, 'Incorrect Answer', Colors.red, false, 2);
                if (quizList[pos].correctAnswer == quizList[pos].answerOne) {
                  colorAnsOne = Colors.green;
                  colorAnsTwo = Colors.white;
                  colorAnsThree = Colors.white;
                  colorAnsFour = Colors.white;
                  isQuestionSelect = true;
                } else if (quizList[pos].correctAnswer ==
                    quizList[pos].answerTwo) {
                  colorAnsOne = Colors.white;
                  colorAnsTwo = Colors.green;
                  colorAnsThree = Colors.white;
                  colorAnsFour = Colors.white;
                  isQuestionSelect = true;
                } else if (quizList[pos].correctAnswer ==
                    quizList[pos].answerThree) {
                  colorAnsOne = Colors.white;
                  colorAnsTwo = Colors.white;
                  colorAnsThree = Colors.green;
                  colorAnsFour = Colors.white;
                  isQuestionSelect = true;
                } else if (quizList[pos].correctAnswer ==
                    quizList[pos].answerFour) {
                  colorAnsOne = Colors.white;
                  colorAnsTwo = Colors.white;
                  colorAnsThree = Colors.white;
                  colorAnsFour = Colors.green;
                  isQuestionSelect = true;
                }

                if (answerText == quizList[pos].answerOne) {
                  colorAnsOne = Colors.red;
                } else if (answerText == quizList[pos].answerTwo) {
                  colorAnsTwo = Colors.red;
                } else if (answerText == quizList[pos].answerThree) {
                  colorAnsThree = Colors.red;
                } else if (answerText == quizList[pos].answerFour) {
                  colorAnsFour = Colors.red;
                }
              }

              setState(() {
                setStateTask(false);
                storeAnswers();
                startTime();
              });
            }),
      );
    } else {
      return new Container();
    }
  }

  void storeAnswers() {
    AnsModel ansModel = new AnsModel(quizList[pos].key, answerText);
    ansList.add(ansModel);
  }

  void setStateTask(isTaskDone) {
    setState(() {
      _saving = isTaskDone;
    });
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, nextQuestion);
  }

  void nextQuestion() {
    colorAnsOne = Colors.white;
    colorAnsTwo = Colors.white;
    colorAnsThree = Colors.white;
    colorAnsFour = Colors.white;
    isQuestionSelect = false;

    pos++;
    if (pos == quizList.length) {
      difficultyLevel = quizList[pos - 1].difficulty;
      if (score == 0) {
        learningRate = -10;
      } else if (score >= 1 && score <= 3) {
        learningRate = -5;
      } else if (score >= 4 && score <= 5) {
        learningRate = 1;
      } else if (score >= 6 && score <= 8) {
        learningRate = 5;
      } else if (score >= 9 && score <= 10) {
        learningRate = 10;
        skipNext10Step = true;
      } else {
        learningRate = 0;
      }

//      if (!isMatch) {
//        session = limitFirstQuiz ~/ 10;
//      }

      session++;

      print('Session>>' + session.toString());
      print('LearningRate>>' + learningRate.toString());
      print('AnsListLenght>>' + ansList.length.toString());

      _updateUserDifficulty();
      _updateUserDifficultyInPref();
      _updateSessionPref();
      _setLearningRate();
      _submitQuizAnswer();
      _showScoreDialog();
      return;
    }

    setStateTask(false);
  }

  void _showScoreDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Center(
            child: Column(
              children: <Widget>[
                new Text('Session $session completed',
                    style: getTextStyleSnackbar(Colors.black)),
                Divider(
                  height: 10.0,
                  color: Colors.transparent,
                ),
                new Text('You Scored $score out of ${quizList.length}',
                    style: getTextStyleSnackbar(Colors.black)),
                Divider(
                  height: 10.0,
                  color: Colors.transparent,
                ),
                new Text('Your Learning Rate is $learningRate',
                    style: getTextStyleSnackbar(Colors.black)),
              ],
            ),
          ),
          contentPadding: EdgeInsets.all(15.0),
          children: <Widget>[
            new MaterialButton(
              child: new Text('Check your Scorecard',
                  style: getTextStyleButtons()),
              color: Colors.red,
              padding: EdgeInsets.all(10.0),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(this.context);
                widget.closeCatWidget();
              },
            ),
            new MaterialButton(
              child: new Text('Next Session', style: getTextStyleButtons()),
              color: Colors.green,
              padding: EdgeInsets.all(10.0),
              onPressed: () {
                Navigator.of(context).pop();
                _resetValues();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitQuizAnswer() async {
    for (int i = 0; i < ansList.length; i++) {
      String category;
      String quizType;
      if (widget.catName != null && widget.catName != '') {
        category = widget.catName;
        quizType = 'CategoryWise';
      } else {
        category = quizList[i].category;
        quizType = 'AnythingGoes';
      }
      try {
        await firebaseDbAuth
            .quizAnswer(
                quizAnsReference,
                userId,
                email,
                name,
                widget.subjectName,
                category,
                grade,
                ansList[i].questionKey,
                ansList[i].answerText,
                quizType)
            .catchError((e) {
          print(e);
          return;
        });
        if (i == ansList.length) {
          print('Success in Quiz Ans');
          ansList.clear();
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _updateUserDifficulty() async {
    try {
      await firebaseDbAuth.updateUserLastSeen(usersReference, userId);
      await firebaseDbAuth
          .updateUserDifficultyLevel(usersReference, userId, difficultyLevel)
          .catchError((e) {
        print(e);
        return;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _setLearningRate() async {
    try {
      await firebaseDbAuth
          .setLearningRate(
              studentLearningRateReference,
              userId,
              session.toString(),
              learningRate.toString(),
              grade,
              widget.subjectName,
              score.toString(),
              difficultyLevel)
          .catchError((e) {
        print(e);
        return;
      });
      //print('Success in Learning Rate');
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color,
      bool showActionButton, int seconds) {
    final snackBar = new SnackBar(
        action: _snackBarAction(showActionButton),
        duration: Duration(seconds: seconds),
        content: new Text(message,
            style: getTextStyleSnackbar(color), textAlign: TextAlign.center),
        backgroundColor: Colors.white);

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget _snackBarAction(bool showActionButton) {
    if (showActionButton) {
      return SnackBarAction(
          label: 'Reload Quiz',
          onPressed: () {
            pos = 0;
            score = 0;
            setState(() {});
          });
    } else {
      return null;
    }
  }

  void _resetValues() {
    score = 0;
    pos = 0;
    if (quizList != null && quizList.length > 0) {
      quizList.clear();
    }
    if (ansList != null && ansList.length > 0) {
      ansList.clear();
    }
    setStateTask(true);
    userId = '';
    grade = '';
    email = '';
    name = '';
    difficultyLevel = '';
    question = '';
    answerOne = '';
    answerTwo = '';
    answerThree = '';
    answerFour = '';
    answerText = '';

    colorAnsOne = Colors.white;
    colorAnsTwo = Colors.white;
    colorAnsThree = Colors.white;
    colorAnsFour = Colors.white;

    isQuestionSelect = false;

    limitFirstMatch = 1000;
    limitFirstQuiz = 10;

    startPosMatch = '0';
    endPosMatch = '999';
    startPosQuiz = '0';
    endPosQuiz = '9';

    session = 0;
    isMatch = false;
    _isGradeExits = true;

    _getUserDataFromPref();
  }

  TextStyle getTextStyle() {
    return TextStyle(color: Colors.black, fontSize: 18.0, fontFamily: 'nova');
  }

  TextStyle getTextStyleButtons() {
    return TextStyle(
        color: Colors.white, fontSize: 18.0, fontFamily: 'novabold');
  }

  TextStyle getTextStyleSnackbar(Color color) {
    return TextStyle(color: color, fontSize: 16.0, fontFamily: 'novabold');
  }

  Future<void> _updateUserDifficultyInPref() async {
    userModel.difficultyLevel = difficultyLevel;
    var userString = jsonEncode(userModel);
    await SharedPreferencesHelper.setUser(userString);
  }

  Future<void> _updateSessionPref() async {
    await SharedPreferencesHelper.setSession(session);
  }
}
