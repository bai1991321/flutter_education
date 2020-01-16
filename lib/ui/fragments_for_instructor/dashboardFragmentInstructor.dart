import 'dart:async';
import 'dart:core';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:education_app/firebase_database/firebase_database.dart';
import 'package:education_app/model/ansModel.dart';
import 'package:education_app/model/quizModel.dart';
import 'package:education_app/model/subjects_model.dart';
import 'package:education_app/model/userRankingModel.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/commonUtils.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardFragmentInstructor extends StatefulWidget {
  const DashboardFragmentInstructor();

  @override
  _DashboardFragmentInstructorState createState() =>
      _DashboardFragmentInstructorState();
}

class _DashboardFragmentInstructorState
    extends State<DashboardFragmentInstructor> {
  final FirebaseDbAuth firebaseDbAuth = new FirebaseDbAuth();

  final usersReference = FirebaseDatabase.instance.reference().child('Users');

  final studentLearnRateReference =
      FirebaseDatabase.instance.reference().child('StudentLearningRate');

  final subjectReference = FirebaseDatabase.instance
      .reference()
      .child(StringConstants.student + 'Subjects');

  final quizAnsReference =
      FirebaseDatabase.instance.reference().child('QuizAnswer');

  final quizMasterQuestionsReference =
      FirebaseDatabase.instance.reference().child('MasterQuestion');

  final quizQuesReference =
      FirebaseDatabase.instance.reference().child('QuizQuestion');

  StreamSubscription<Event> _onSubjectAdded;

  Map<dynamic, dynamic> _valueSession;
  Map<dynamic, dynamic> _quizSession;
  Map<dynamic, dynamic> _quizQuesSession;

  String userId;
  String difficultyLevel;
  String lastSeen;
  String subject;
  String scoreLastSession = '';
  String schoolName = 'ABC';
  String state = 'ABC';
  String country = 'US';
  String _mUserId;
  String _mDifficultyLevel;
  String _mLastSeen;
  String _mSubject;

  int indexQuestion = 0;
  int indexPerformance = 0;
  int indexRanking = 0;
  int indexCompleteness = 0;

  int difference = 0;
  int lastValSession = 0;
  int _totalQuestionLenght = 0;
  int _acceptedQuestionLenght = 0;
  int _mTotalSchoolLenght = 0;
  int _mTotalStateLenght = 0;
  int _mTotalCountryLenght = 0;
  int _mRankBySchool = 0;
  int _mRankByState = 0;
  int _mRankByCountry = 0;
  int _mDifference = 0;
  int _mTotalSessionLenght = 0;
  int _mTotalAttempts = 0;
  int _mCatAttempts = 0;

  var userModel;

  BuildContext context;

  bool _saving = true;
  bool _animate = true;
  bool _isRunFirstRun = false;
  bool _isSubjectClickForRank = false;

  double per = 0;
  double _mPer = 0;
  double _perCompare = 0;

  final List<Tab> myTopBarTabs = <Tab>[
    new Tab(text: 'Questions Library', icon: Container()),
    new Tab(text: 'Media Library', icon: Container()),
    new Tab(text: 'Performance', icon: Container()),
    new Tab(text: 'Completeness', icon: Container()),
    new Tab(text: 'Ranking', icon: Container()),
  ];

  List<charts.Series> seriesListPerformance;
  List<charts.Series> seriesListAttempts;
  List<SubjectsModel> subjectList;
  List<SubjectsModel> subjectList2;
  List<LinearPerformance> listLinearPer;
  List<LinearAttempts> listLinearAttempts;
  List<AnsModel> questionList;
  List<UserRankingModel> userRankingListWithSchoolName;
  List<UserRankingModel> userRankingListWithStateName;
  List<String> categoryArray;
  List<QuizModel> quizQuestionList;

  @override
  void initState() {
    super.initState();
    quizQuestionList = new List();
    seriesListPerformance = new List();
    listLinearPer = new List();

    _getUserDataFromPref();

    subjectList = new List();
    subjectList2 = new List();
    subjectList.add(new SubjectsModel(StringConstants.all_ques,
        StringConstants.all_color, StringConstants.all_per_logo));
    subjectList2.add(new SubjectsModel(StringConstants.all,
        StringConstants.all_color, StringConstants.all_per_logo));
    _onSubjectAdded =
        subjectReference.onChildAdded.listen(_onSubjectStudentAdded);
  }

  @override
  void dispose() {
    try {
      _onSubjectAdded.cancel();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  void _onSubjectStudentAdded(Event event) {
    subjectList.add(new SubjectsModel.fromSnapshot(event.snapshot));
    subjectList2.add(new SubjectsModel.fromSnapshot(event.snapshot));
    if (subjectList.length == 6 && subjectList2.length == 6) {
      setStateTask(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new DefaultTabController(
      length: myTopBarTabs.length,
      initialIndex: 0,
      child: new Scaffold(
        appBar: new TabBar(
          tabs: myTopBarTabs,
          isScrollable: true,
          indicatorColor: const Color(AppColors.primaryDarkColor),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.all(10),
          labelStyle: TextStyle(
            color: Colors.black,
            letterSpacing: 1,
            fontFamily: 'nova',
            fontSize: 16.0,
          ),
        ),
        body: new Theme(
          data: Theme.of(context).copyWith(
              accentColor: const Color(AppColors.primaryColor),
              primaryColor: const Color(AppColors.primaryColor)),
          child: new ProgressHUD(
              inAsyncCall: _saving, child: _buildWidget(), opacity: 0.0),
        ),
      ),
    );
  }

  Widget _buildWidget() {
    return new Builder(
      builder: (context) => Container(
            child: getTabBarPagesTop(),
          ),
    );
  }

  Widget getTabBarPagesTop() {
    if (subjectList.length == 6) {
      return new TabBarView(
        children: <Widget>[
          getTabForQuestions(),
          getTabForMediaLibrary(),
          getTabForPerformance(),
          getTabForCompleteness(),
          getTabForRank(),
        ],
      );
    }
    return new Container();
  }

  Widget getTabForQuestions() {
    return new Builder(
      builder: (context) => Container(
              child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  height: 100.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subjectList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItemsQuestions(index);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: Container(child: textWidgetQuestion())),
              SliverToBoxAdapter(
                child: Container(
                  height: 320.0,
                  child: bodyWidgetQuestionList(),
                ),
              ),
            ],
          )),
    );
  }

  Widget getTabForMediaLibrary() {
    return new Container();
  }

  Widget getTabForPerformance() {
    return new Builder(
      builder: (context) => Container(
              child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  height: 100.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subjectList2.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItemsForPerformance(index);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                  child: Container(child: textWidgetPerformance())),
              SliverToBoxAdapter(
                  child: Container(
                child: _drawLineChart(),
                width: double.infinity,
                height: 260.0,
              )),
            ],
          )),
    );
  }

  Widget getTabForCompleteness() {
    return new Builder(
      builder: (context) => Container(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Container(
                    height: 100.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: subjectList2.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildItemsCompleteness(index);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                    child: Container(child: textWidgetCompleteness())),
              ],
            ),
          ),
    );
  }

  Widget getTabForRank() {
    return new Builder(
      builder: (context) => Container(
              child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Container(
                  height: 100.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subjectList2.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItemsRank(index);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: Container(child: textWidgetRank())),
              SliverFixedExtentList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    // To convert this infinite list to a list with three items,
                    // uncomment the following line:
                    // if (index > 3) return null;
                    return bodyWidgetRank(index);
                  },
                  // Or, uncomment the following line:
                  childCount: 3,
                ),
                itemExtent: 100.0,
              ),
            ],
          )),
    );
  }

  Widget _buildItemsQuestions(int index) {
    return new Container(
      child: new Column(
        children: <Widget>[
          FlatButton(
            color: Colors.transparent,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: new Image.network(
                    subjectList[index].icon,
                    width: 22.0,
                    height: 22.0,
                    color: new HexColor(subjectList[index].color),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: new Text(subjectList[index].subjectName,
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1,
                        fontFamily: 'nova',
                        fontSize: 16.0,
                      )),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Container(
                    height: 2,
                    width: 80.0,
                    color: const Color(AppColors.primaryColor),
                  ),
                )
              ],
            ),
            onPressed: () {
              setStateTask(false);
              this.indexQuestion = index;

              if (quizQuestionList.length > 0) {
                quizQuestionList.clear();
              }

              if (subjectList[index].subjectName == StringConstants.all_ques) {
                _getQuestionsList('');
              } else {
                _getQuestionsList(subjectList[index].subjectName);
              }
            },
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsForPerformance(int index) {
    return new Container(
      child: new Column(
        children: <Widget>[
          FlatButton(
            color: Colors.transparent,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: new Image.network(
                    subjectList2[index].icon,
                    width: 22.0,
                    height: 22.0,
                    color: new HexColor(subjectList2[index].color),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: new Text(subjectList2[index].subjectName,
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1,
                        fontFamily: 'nova',
                        fontSize: 16.0,
                      )),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Container(
                    height: 2,
                    width: 80.0,
                    color: const Color(AppColors.primaryColor),
                  ),
                )
              ],
            ),
            onPressed: () {
              setStateTask(false);
              this.indexPerformance = index;

              if (seriesListPerformance != null &&
                  seriesListPerformance.length > 0) {
                seriesListPerformance.clear();
              }

              if (listLinearPer != null && listLinearPer.length > 0) {
                listLinearPer.clear();
              }
              _totalQuestionLenght = 0;
              _acceptedQuestionLenght = 0;
              if (subjectList2[index].subjectName == StringConstants.all) {
                _getTotalQuestions('');
              } else {
                _getTotalQuestions(subjectList2[index].subjectName);
              }
            },
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCompleteness(int index) {
    return new Container(
      child: new Column(
        children: <Widget>[
          FlatButton(
            color: Colors.transparent,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: new Image.network(
                    subjectList2[index].icon,
                    width: 22.0,
                    height: 22.0,
                    color: new HexColor(subjectList2[index].color),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: new Text(subjectList2[index].subjectName,
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1,
                        fontFamily: 'nova',
                        fontSize: 16.0,
                      )),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Container(
                    height: 2,
                    width: 60.0,
                    color: const Color(AppColors.primaryColor),
                  ),
                )
              ],
            ),
            onPressed: () {
              setStateTask(false);
              this.indexCompleteness = index;

              if (subjectList2[index].subjectName == StringConstants.all) {
              } else {}
            },
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsRank(int index) {
    return new Container(
      child: new Column(
        children: <Widget>[
          FlatButton(
            color: Colors.transparent,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: new Image.network(
                    subjectList2[index].icon,
                    width: 22.0,
                    height: 22.0,
                    color: new HexColor(subjectList2[index].color),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: new Text(subjectList2[index].subjectName,
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1,
                        fontFamily: 'nova',
                        fontSize: 16.0,
                      )),
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Container(
                    height: 2,
                    width: 60.0,
                    color: const Color(AppColors.primaryColor),
                  ),
                )
              ],
            ),
            onPressed: () {
              setStateTask(false);
              this.indexRanking = index;
              if (subjectList2[index].subjectName == StringConstants.all) {
              } else {}
            },
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
  }

  Widget textWidgetQuestion() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            subjectList[indexQuestion].subjectName,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'novabold',
              fontSize: 18.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget textWidgetQuestions() {
    if (quizQuestionList.length != 0) {
      return Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Question',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'novabold',
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Answers',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'novabold',
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ))
        ],
      );
    } else {
      return new Container();
    }
  }

  Widget textWidgetPerformance() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            subjectList2[indexPerformance].subjectName,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'novabold',
              fontSize: 18.0,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Performance',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'novabold',
              fontSize: 16.0,
            ),
          ),
        )
      ],
    );
  }

  Widget textWidgetCompleteness() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            subjectList2[indexCompleteness].subjectName,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'novabold',
              fontSize: 18.0,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Completeness',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'novabold',
              fontSize: 16.0,
            ),
          ),
        )
      ],
    );
  }

  Widget textWidgetRank() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            subjectList2[indexRanking].subjectName,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'novabold',
              fontSize: 18.0,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Ranking',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'novabold',
              fontSize: 16.0,
            ),
          ),
        )
      ],
    );
  }

  Widget bodyWidgetQuestionList() {
    if (quizQuestionList.length != 0) {
      return CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: Container(child: textWidgetQuestions())),
          SliverFixedExtentList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // To convert this infinite list to a list with three items,
                // uncomment the following line:
                // if (index > 3) return null;
                return bodyWidgetQuestions(index);
              },
              // Or, uncomment the following line:
              childCount: quizQuestionList.length,
            ),
            itemExtent: 40.0,
          ),
        ],
      );
    } else {
      return Container(
        child: Center(
          child: Text('Result Not Found'),
        ),
      );
    }
  }

  Widget bodyWidgetQuestions(int index) {
    if (quizQuestionList.length != 0) {
      int indexNew = index;
      indexNew++;
      return new Container(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Center(
                    child: Text(
                      'Q$indexNew',
                      style: getTextStyleForLastSession(),
                    ),
                  ),
                  new Center(
                    child: Text(
                      quizQuestionList[index].question,
                      style: getTextStyleForLastSession(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 5,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      quizQuestionList[index].correctAnswer,
                      style: getTextStyleForLastSession(),
                    ),
                  ],
                ))
          ],
        ),
      );
    } else {
      return Container(
        child: Center(
          child: Text('Result Not Found'),
        ),
      );
    }
  }

  Widget bodyWidgetRank(int index) {
    List<Color> listColor;
    Color shadowColor;
    String text;
    String range;
    if (index == 0) {
      listColor = AppColors.gradientListTileOne;
      shadowColor = const Color(0xFF6279D9);
      text = schoolName;
      range = '$_mRankBySchool/$_mTotalSchoolLenght';
    } else if (index == 1) {
      listColor = AppColors.gradientListTileTwo;
      shadowColor = const Color(0xFFFE7A7D);
      text = state;
      range = '$_mRankByState/$_mTotalStateLenght';
    } else if (index == 2) {
      listColor = AppColors.gradientListTileThree;
      shadowColor = const Color(0xFFB669F1);
      text = country;
      range = '$_mRankByCountry/$_mTotalCountryLenght';
    }

    return new Container(
        margin: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 15.0,
        ),
        child: new Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 0.0),
                  // 10% of the width, so there are ten blinds.
                  colors: listColor,
                  // whitish to gray
                  tileMode:
                      TileMode.mirror, // repeats the gradient over the canvas
                ),
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.circular(2.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: shadowColor,
                    blurRadius: 3.0,
                    offset: new Offset(0.0, 3.0),
                  ),
                ],
              ),
              child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Text(
                          text,
                          maxLines: 1,
                          style: getTextStyle(),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: new Center(
                          child: Text(
                            range,
                            maxLines: 1,
                            style: getTextStyleOne(),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ));
  }

  Widget _drawLineChart() {
    if (seriesListPerformance.length != 0) {
      return new charts.LineChart(seriesListPerformance,
          animate: _animate,
          defaultRenderer: new charts.LineRendererConfig(
              includePoints: true,
              includeArea: true,
              includeLine: true,
              radiusPx: 5.0));
    } else {
      return Container(
        child: Center(
          child: Text('Result Not Found'),
        ),
      );
    }
  }

  Widget _drawPieChart() {
    if (seriesListAttempts.length != 0) {
      return new charts.PieChart(seriesListAttempts, animate: _animate);
    } else {
      return Container(
        child: Center(
          child: Text('Result Not Found'),
        ),
      );
    }
  }

  void setStateTask(isTaskDone) {
    if (this.mounted) {
      setState(() {
        _saving = isTaskDone;
      });
    }
  }

  Future<void> _getUserDataFromPref() async {
    try {
      if (await SharedPreferencesHelper.getUserId() != null) {
        userId = await SharedPreferencesHelper.getUserId();
        print(userId);
        if (userId != null) {
          _getQuestionsList('');
          _getUserValues();
        } else {
          setStateTask(false);
        }
      }
    } catch (e) {
      setStateTask(false);
      print(e);
    }
  }

  Future<void> _getQuestionsList(String subject) async {
    try {
      quizQuesReference
          .child(userId)
          .orderByKey()
          .onChildAdded
          .listen((Event event) {
        if (event.snapshot != null) {
          _quizQuesSession = event.snapshot.value;
          Map<dynamic, dynamic> map = _quizQuesSession;
          if (map['status'] == '1') {
            if (subject != '') {
              if (subject == map['subject']) {
                setQuestions(map);
              }
            } else {
              setQuestions(map);
            }
          }

//          for (final key in map.keys) {
//            Map<dynamic, dynamic> map2 = map[key];
//            if (map2['status'] == '1') {
//              if (subject != '') {
//                if (subject == map2['subject']) {
//                  setQuestions(map2);
//                }
//              } else {
//                setQuestions(map2);
//              }
//            }
//          }
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  void setQuestions(Map<dynamic, dynamic> map) {
    QuizModel quizModel = new QuizModel(
        '',
        '',
        '',
        map['subject'],
        map['question'],
        map['category'],
        map['answerOne'],
        map['answerTwo'],
        map['answerThree'],
        map['answerFour'],
        map['correctAnswer'],
        '',
        '');
    quizQuestionList.add(quizModel);
  }

  void doneQuestionTask() {
    setStateTask(false);
  }

  Future<void> _getAttempts(String _mSubjectAttempts) async {
    _mTotalAttempts = 0;
    try {
      await quizAnsReference
          .child(userId)
          .orderByKey()
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          _quizSession = snapshot.value;
          Map<dynamic, dynamic> map = _quizSession;
          for (final key in map.keys) {
            Map<dynamic, dynamic> map2 = map[key];
            if (_mSubjectAttempts != '') {
              if (_mSubjectAttempts == map2['subject']) {
                _mTotalAttempts++;
                if (!categoryArray.contains(map2['category'])) {
                  categoryArray.add(map2['category']);
                }
              }
            } else {
              _mTotalAttempts++;
              if (!categoryArray.contains(map2['category'])) {
                categoryArray.add(map2['category']);
              }
            }
          }
        }

        print('Total Attempts Lenght' + _mTotalAttempts.toString());
        if (categoryArray.length > 0) {
          categoryArray.sort((x, y) => x.length.compareTo(y.length));
          for (var cat in categoryArray) {
            print(cat);
            _getAttemptsByCat(_mSubjectAttempts, cat);
          }
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  Future<void> _getAttemptsByCat(String _mSubjectAttempts, String cat) async {
    try {
      await quizAnsReference
          .child(userId)
          .orderByKey()
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          _quizSession = snapshot.value;
          Map<dynamic, dynamic> map = _quizSession;
          _mCatAttempts = 0;
          for (final key in map.keys) {
            Map<dynamic, dynamic> map2 = map[key];
            if (_mSubjectAttempts != '') {
              if (_mSubjectAttempts == map2['subject']) {
                if (cat == map2['category']) {
                  _mCatAttempts++;
                }
              }
            } else {
              if (cat == map2['category']) {
                _mCatAttempts++;
              }
            }
          }
          calculatePercentage(_mTotalAttempts, _mCatAttempts);
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  void calculatePercentage(int totalAttempts, int catAttempts) {
    print('totalAttempts>>' + totalAttempts.toString());
    print('catAttempts>>' + catAttempts.toString());
    double perAttempts = (totalAttempts * catAttempts) / 100;
    print('perAttempts>>' + perAttempts.toString());
    listLinearAttempts.add(new LinearAttempts(catAttempts, perAttempts));
    seriesListAttempts = _createAttemptsPercentage();
    setStateTask(false);
  }

  Future<void> _getLastSessionAttempts() async {
    try {
      quizAnsReference
          .child(userId)
          .orderByKey()
          .limitToLast(10)
          .onChildAdded
          .listen((Event event) {
        if (event.snapshot.value != null) {
          _quizSession = event.snapshot.value;
          _getLastSessionAttemptedQuestions(
              _quizSession['grade'],
              _quizSession['subject'],
              _quizSession['category'],
              _quizSession['questionKey'],
              _quizSession['quizType']);
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  Future<void> _getLastSessionAttemptedQuestions(String grade, String subject,
      String category, String questionKey, String quizType) async {
    try {
      if (quizType == 'AnythingGoes') {
        category = 'AnythingGoes';
      }
      await quizMasterQuestionsReference
          .child(grade)
          .child(subject)
          .child(category)
          .child(questionKey)
          .orderByKey()
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          AnsModel ansModel = new AnsModel(
              snapshot.value['question'], snapshot.value['correctAnswer']);
          if (questionList != null) {
            questionList.add(ansModel);
          }
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  Future<void> _getScoreOfLastSessionCompleted() async {
    try {
      studentLearnRateReference
          .child(userId)
          .orderByKey()
          .limitToLast(1)
          .onChildAdded
          .listen((Event event) {
        if (event.snapshot.value != null) {
          scoreLastSession = event.snapshot.value['score'];
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  Future<void> _getSchoolNameForRanking(String subject) async {
    this._mSubject = subject;
    try {
      usersReference
          .child(userId)
          .orderByKey()
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          schoolName = snapshot.value['schoolName'];
          state = snapshot.value['state'];
          _mDifficultyLevel = snapshot.value['difficultyLevel'];
          _mLastSeen = snapshot.value['lastSeen'];
          _mDifference = int.parse(CommonUtils.calculateDifference(_mLastSeen));

          print('CurrentUser_mDifficultyLevel>>>' + _mDifficultyLevel);
          print('CurrentUser_mLastSeen>>>' + _mLastSeen);
          print('CurrentUser_mDifference>>>' + _mDifference.toString());
          _isRunFirstRun = true;
          _getTotalSessionForRank('', userId, _mSubject);
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  Future<void> _compareStudentsWithSchoolName() async {
//    _mTotalSchoolLenght = 0;
//    _mRankBySchool = 0;
    try {
      await usersReference.orderByKey().once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          Map<dynamic, dynamic> map = snapshot.value;
          for (final key in map.keys) {
            if (userId != key) {
              Map<dynamic, dynamic> map2 = map[key];
              if (map2['schoolName'] != '') {
                if (schoolName == map2['schoolName']) {
                  _mUserId = key;
                  _mDifficultyLevel = map2['difficultyLevel'];
                  _mLastSeen = map2['lastSeen'];
                  _mDifference =
                      int.parse(CommonUtils.calculateDifference(_mLastSeen));

                  print('_mUserId School>>' + _mUserId);
                  print('_mDifficultyLevel School>>>' + _mDifficultyLevel);
                  print('_mLastSeen School>>>' + _mLastSeen);
                  print('_mDifference School>>>' + _mDifference.toString());

                  _getTotalSessionForRank('School', _mUserId, '');
                }
              }
            }
          }
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _compareStudentsWithStateName() async {
//    _mTotalStateLenght = 0;
//    _mRankByState = 0;
    try {
      await usersReference.orderByKey().once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          Map<dynamic, dynamic> map = snapshot.value;
          for (final key in map.keys) {
            if (userId != key) {
              Map<dynamic, dynamic> map2 = map[key];
              if (map2['state'] != '') {
                if (state == map2['state']) {
                  _mUserId = key;
                  _mDifficultyLevel = map2['difficultyLevel'];
                  _mLastSeen = map2['lastSeen'];
                  _mDifference =
                      int.parse(CommonUtils.calculateDifference(_mLastSeen));

                  print('_mUserId State>>' + _mUserId);
                  print('_mDifficultyLevel State>>>' + _mDifficultyLevel);
                  print('_mLastSeen State>>>' + _mLastSeen);
                  print('_mDifference State>>>' + _mDifference.toString());

                  _getTotalSessionForRank('State', _mUserId, '');
                }
              }
            }
          }
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  Future<int> _getTotalSessionForRank(
      String isComingFrom, String userId, String subject) async {
    this._mSubject = subject;
    this._mUserId = userId;
    _mTotalSessionLenght = 0;
    try {
      await studentLearnRateReference
          .child(userId)
          .once()
          .then((DataSnapshot snapshot) {
        _valueSession = snapshot.value;
        if (_valueSession != null) {
          if (subject == '') {
            _mTotalSessionLenght = _valueSession.length;
          } else {
            for (final key in _valueSession.keys) {
              Map<dynamic, dynamic> map = _valueSession[key];
              if (subject == map['subject']) {
                _mTotalSessionLenght++;
              }
            }
          }
        }

        if (_mTotalSessionLenght != 0) {
          print('Total Session Lenght>>$_mTotalSessionLenght');
          _sessionCompletedForRank(isComingFrom, _mUserId, _mSubject);
        }
      });
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
      return _mTotalSessionLenght;
    }
    return _mTotalSessionLenght;
  }

  Future<void> _sessionCompletedForRank(
      String isComingFrom, String userId, String subject) async {
    this._mSubject = subject;
    _mPer = 0;
    try {
      studentLearnRateReference
          .child(userId)
          .orderByKey()
          .limitToLast(1)
          .onChildAdded
          .listen((Event event) {
        _valueSession = event.snapshot.value;

        if (_valueSession != null) {
          if (_mSubject != '') {
            if (subject == _valueSession['subject']) {
              _mDifficultyLevel = _valueSession['difficultyLevel'];
              print('_mDifficultyLevelU>>' + _mDifficultyLevel);
              calculatePerformanceForRank(isComingFrom, _mTotalSessionLenght);
            }
          } else {
            _mDifficultyLevel = _valueSession['difficultyLevel'];
            print('_mDifficultyLevelD>>' + _mDifficultyLevel);
            calculatePerformanceForRank(isComingFrom, _mTotalSessionLenght);
          }
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  void calculatePerformanceForRank(String isComingFrom, int valSession) {
    if (_mDifference != 0) {
      _mPer = double.parse(_mDifficultyLevel) * valSession * (1 / _mDifference);
    } else {
      _mPer = double.parse(_mDifficultyLevel) * valSession * 1;
    }

    if (isComingFrom == 'School') {
      _mTotalSchoolLenght++;
      UserRankingModel userRankingModel = new UserRankingModel(_mUserId, _mPer);
      userRankingListWithSchoolName.add(userRankingModel);
      userRankingListWithSchoolName
          .sort((y, x) => x.performance.compareTo(y.performance));
      print(
          'LL For School>>' + userRankingListWithSchoolName.length.toString());

      for (var userRankingModel in userRankingListWithSchoolName) {
        if (_perCompare == userRankingModel.performance) {
          _mRankBySchool =
              userRankingListWithSchoolName.indexOf(userRankingModel) + 1;
          print('_mRankBySchool>>' + _mRankBySchool.toString());

          if (_isSubjectClickForRank && _mRankBySchool > 0) {
            print('Enter Up');
            setStateTask(false);
            _isSubjectClickForRank = false;
          }
        }
      }
    } else if (isComingFrom == 'State') {
      _mTotalStateLenght++;
      UserRankingModel userRankingModel = new UserRankingModel(_mUserId, _mPer);
      userRankingListWithStateName.add(userRankingModel);
      userRankingListWithStateName
          .sort((y, x) => x.performance.compareTo(y.performance));
      print('LL For State>>' + userRankingListWithStateName.length.toString());

      for (var userRankingModel in userRankingListWithStateName) {
        if (_perCompare == userRankingModel.performance) {
          _mRankByState =
              userRankingListWithStateName.indexOf(userRankingModel) + 1;
          print('_mRankByState>>' + _mRankByState.toString());

          if (_isSubjectClickForRank && _mRankByState > 0) {
            print('Enter Down');
            setStateTask(false);
            _isSubjectClickForRank = false;
          }
        }
      }
    } else {
      _perCompare = _mPer;
      UserRankingModel userRankingModel = new UserRankingModel(_mUserId, _mPer);
      userRankingListWithSchoolName.add(userRankingModel);
      userRankingListWithStateName.add(userRankingModel);
      _mTotalSchoolLenght++;
      _mTotalStateLenght++;
      _mRankByState++;
      _mRankBySchool++;
      print('Here>>' + _perCompare.toString());
      setStateTask(false);
    }

    print('Peformance For Rank>>' + _mPer.toString());

    if (_isRunFirstRun) {
      _isRunFirstRun = false;
      _compareStudentsWithSchoolName();
      _compareStudentsWithStateName();
    }
  }

  Future<void> _getUserValues() async {
    try {
      await usersReference.child(userId).once().then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          lastSeen = snapshot.value['lastSeen'];
          print(lastSeen);
          difference = int.parse(CommonUtils.calculateDifference(lastSeen));
          print(difference);
          _getTotalQuestions('');
        } else {
          setStateTask(false);
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  Future<void> _getTotalQuestions(String subject) async {
    this.subject = subject;
    try {
      await quizQuesReference
          .child(userId)
          .once()
          .then((DataSnapshot snapshot) {
        _valueSession = snapshot.value;
        if (_valueSession != null) {
          _totalQuestionLenght = _valueSession.length;
          for (final key in _valueSession.keys) {
            Map<dynamic, dynamic> map = _valueSession[key];
            if (map['status'] == '1') {
              if (subject == '') {
                _acceptedQuestionLenght++;
              } else {
                if (subject == map['subject']) {
                  _acceptedQuestionLenght++;
                }
              }
            }
          }
        } else {
          setStateTask(false);
        }
      }).whenComplete(doneTask);
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
    }
  }

  void doneTask() {
    print('totalQuestionLenght>>' + _totalQuestionLenght.toString());
    print('acceptedQuestionLenght>>' + _acceptedQuestionLenght.toString());
    listLinearPer.add(new LinearPerformance(0, 0.0));
    calculatePerformance();
//    if (_totalQuestionLenght != 0 && subject == '') {
//      _performanceOverAll();
//    } else if (_totalQuestionLenght != 0 && subject != '') {
//      _performanceSubjectWise(subject);
//    } else {
//      setStateTask(false);
//    }
    //_updateLastSeen();
    setStateTask(false);
  }

  Future<void> _updateLastSeen() async {
    try {
      await firebaseDbAuth.updateUserLastSeen(usersReference, userId);
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
    }
  }

//  Future<void> _performanceOverAll() async {
//    per = 0;
//    int valSession = 5;
//    int sessionLenght = 1;
//    int newVal = 1;
//    listLinearPer.add(new LinearPerformance(0, 0.0));
//
//    try {
//      studentLearnRateReference
//          .child(userId)
//          .orderByKey()
//          .onChildAdded
//          .listen((Event event) {
//        _valueSession = event.snapshot.value;
//
//        if (_valueSession != null) {
//          //print('sessionLenght>>' + sessionLenght.toString());
//
//          if (sessionLenght == _totalQuestionLenght) {
//            //print('newValDown>>' + newVal.toString());
//            difficultyLevel = _valueSession['difficultyLevel'];
//            //print('difficultyLevelDown>>' + difficultyLevel);
//            calculatePerformance(newVal);
//            setStateTask(false);
//            return;
//          }
//
//          if (sessionLenght == valSession) {
//            difficultyLevel = _valueSession['difficultyLevel'];
//            //print('difficultyLevelUp>>' + difficultyLevel);
//            //print('newValUp>>' + newVal.toString());
//            calculatePerformance(newVal);
//            newVal = 0;
//            valSession = valSession + 5;
//          }
//
//          sessionLenght++;
//          newVal++;
//        } else {
//          setStateTask(false);
//        }
//      });
//    } catch (e) {
//      print('Error: $e');
//      setStateTask(false);
//    }
//  }
//
//  Future<void> _performanceSubjectWise(String subject) async {
//    per = 0;
//    int valSession = 5;
//    int sessionLenght = 1;
//    int newVal = 1;
//    listLinearPer.add(new LinearPerformance(0, 0.0));
//
//    try {
//      studentLearnRateReference
//          .child(userId)
//          .orderByKey()
//          .onChildAdded
//          .listen((Event event) {
//        _valueSession = event.snapshot.value;
//
//        if (_valueSession != null) {
//          //print('sessionLenght>>' + sessionLenght.toString());
//          if (subject == _valueSession['subject']) {
//            if (sessionLenght == _totalQuestionLenght) {
//              //print('newValDown>>' + newVal.toString());
//              difficultyLevel = _valueSession['difficultyLevel'];
//              //print('difficultyLevelDown>>' + difficultyLevel);
//              calculatePerformance(newVal);
//              setStateTask(false);
//              return;
//            }
//
//            if (sessionLenght == valSession) {
//              difficultyLevel = _valueSession['difficultyLevel'];
//              //print('difficultyLevelUp>>' + difficultyLevel);
//              //print('newValUp>>' + newVal.toString());
//              calculatePerformance(newVal);
//              newVal = 0;
//              valSession = valSession + 5;
//            }
//
//            sessionLenght++;
//            newVal++;
//          }
//        } else {
//          setStateTask(false);
//        }
//      });
//    } catch (e) {
//      setStateTask(false);
//      print('Error: $e');
//    }
//  }

  void calculatePerformance() {
    if (difference != 0) {
      per = _acceptedQuestionLenght *
          (_acceptedQuestionLenght / _totalQuestionLenght) *
          (1 / difference);
    } else {
      per = _acceptedQuestionLenght *
          (_acceptedQuestionLenght / _totalQuestionLenght) *
          1;
    }

    print('Performance is>>' + per.toString());

    if (per != 0.0) {
      listLinearPer.add(new LinearPerformance(1, per));
      seriesListPerformance = _createQuestionPerformanceData();
    }
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<LinearPerformance, int>> _createQuestionPerformanceData() {
    if (listLinearPer.length != 0) {
      return [
        new charts.Series<LinearPerformance, int>(
          id: 'Performance',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (LinearPerformance sales, _) => sales.session,
          measureFn: (LinearPerformance sales, _) => sales.performance,
          data: listLinearPer,
        )
      ];
    } else {
      return [];
    }
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<LinearAttempts, int>> _createAttemptsPercentage() {
    if (listLinearAttempts.length != 0) {
      return [
        new charts.Series<LinearAttempts, int>(
          id: 'Percentage',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (LinearAttempts sales, _) => sales.sessionAttempts,
          measureFn: (LinearAttempts sales, _) => sales.percentage,
          data: listLinearAttempts,
        )
      ];
    } else {
      return [];
    }
  }
}

TextStyle getTextStyle() {
  return new TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontSize: 30.0,
      fontFamily: 'nova');
}

TextStyle getTextStyleOne() {
  return new TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontSize: 30.0,
      fontFamily: 'novabold');
}

TextStyle getTextStyleForLastSession() {
  return new TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.black,
      fontSize: 17.0,
      fontFamily: 'nova');
}

/// Sample linear data type.
class LinearPerformance {
  final int session;
  final double performance;

  LinearPerformance(this.session, this.performance);
}

/// Sample linear data type.
class LinearAttempts {
  final int sessionAttempts;
  final double percentage;

  LinearAttempts(this.sessionAttempts, this.percentage);
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
