import 'dart:async';
import 'dart:core';
import 'dart:math' as math;

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:education_app/model/ansCatModel.dart';
import 'package:education_app/model/sessionModel.dart';
import 'package:education_app/model/subjects_model.dart';
import 'package:education_app/model/userRankingModel.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/commonUtils.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/sharePreferenceHelper.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardFragmentStudent extends StatefulWidget {
  const DashboardFragmentStudent();

  @override
  _DashboardFragmentStudentState createState() =>
      _DashboardFragmentStudentState();
}

class _DashboardFragmentStudentState extends State<DashboardFragmentStudent> {
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

  StreamSubscription<Event> _onSubjectAdded;

  Map<dynamic, dynamic> _valueSession;
  Map<dynamic, dynamic> _quizSession;

  String userId;
  String difficultyLevel;
  String lastSeen;
  String subject;
  String scoreLastSession = '';
  String schoolName;
  String state;
  String country = 'US';
  String _mUserId;
  String _mDifficultyLevel;
  String _mLastSeen;
  String _mSubject;

  int index = 0;
  int difference = 0;
  int indexRanking = 0;
  int indexAttempts = 0;
  int _totalSessionLenght = 0;
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
  bool _isSubjectClickForPerformance = false;
  bool _isSubjectClickForAttempts = false;

  double per = 0;
  double _mPer = 0;
  double _perCompare = 0;

  Color color = Colors.black;

  final List<Tab> myTopBarTabs = <Tab>[
    new Tab(text: 'Performance', icon: Container()),
    new Tab(text: 'Ranking', icon: Container()),
    new Tab(text: 'Last Session', icon: Container()),
    new Tab(text: 'Attempts', icon: Container()),
  ];

  List<charts.Series> seriesList;
  List<charts.Series> seriesListAttempts;
  List<SubjectsModel> subjectList;
  List<LinearPerformance> listLinearPer;
  List<LinearAttempts> listLinearAttempts;
  List<AnsCatModel> questionList;
  List<UserRankingModel> userRankingListWithSchoolName;
  List<UserRankingModel> userRankingListWithStateName;
  List<String> categoryArray;
  List<Color> colorArray;

  @override
  void initState() {
    super.initState();
    questionList = new List();
    _getUserDataFromPref();
    subjectList = new List();
    subjectList.add(new SubjectsModel(StringConstants.all,
        StringConstants.all_color, StringConstants.all_per_logo));
    _onSubjectAdded =
        subjectReference.onChildAdded.listen(_onSubjectStudentAdded);

    listLinearPer = new List();
    listLinearAttempts = new List();
    seriesList = new List();
    seriesListAttempts = new List();
    userRankingListWithSchoolName = new List();
    userRankingListWithStateName = new List();
    categoryArray = new List();
    colorArray = new List();
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
    //print('Final Lenght>>' + subjectList.length.toString());
    if (subjectList.length == 6) {
      return new TabBarView(
        children: <Widget>[
          getTabForSubject(),
          getTabForRank(),
          getTabForLastSession(),
          getTabForAttempts()
        ],
      );
    }
    return new Container();
  }

  Widget getTabForSubject() {
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
                      return _buildItems(index);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: Container(child: textWidget(per))),
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
                    itemCount: subjectList.length,
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

  Widget getTabForLastSession() {
    if (scoreLastSession != '' && questionList.length > 0) {
      return new Builder(
        builder: (context) => Container(
                child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                    child: Container(child: textWidgetLastSession())),
                SliverFixedExtentList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // To convert this infinite list to a list with three items,
                      // uncomment the following line:
                      // if (index > 3) return null;
                      return bodyWidgetLastSession(index);
                    },
                    // Or, uncomment the following line:
                    childCount: questionList.length,
                  ),
                  itemExtent: 40.0,
                ),
              ],
            )),
      );
    } else {
      return Container(
        child: Center(
          child: Text('Result Not Found'),
        ),
      );
    }
  }

  Widget getTabForAttempts() {
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
                        return _buildItemsAttempts(index);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                    child: Container(child: textWidgetAttempts())),
              ],
            ),
          ),
    );
  }

  Widget _buildItems(int index) {
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
                    width: 60.0,
                    color: const Color(AppColors.primaryColor),
                  ),
                )
              ],
            ),
            onPressed: () {
              setStateTask(false);
              this.index = index;

              if (seriesList.length > 0) {
                seriesList.clear();
              }

              if (listLinearPer.length > 0) {
                listLinearPer.clear();
              }

              subject = '';
              _isSubjectClickForRank = false;
              _isSubjectClickForPerformance = true;

              if (subjectList[index].subjectName == StringConstants.all) {
                _getTotalSession('');
              } else {
                _getTotalSession(subjectList[index].subjectName);
              }
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
                    width: 60.0,
                    color: const Color(AppColors.primaryColor),
                  ),
                )
              ],
            ),
            onPressed: () {
              setStateTask(false);
              this.indexRanking = index;

              if (userRankingListWithSchoolName.length > 0) {
                userRankingListWithSchoolName.clear();
              }

              if (userRankingListWithStateName.length > 0) {
                userRankingListWithStateName.clear();
              }

              _mTotalSessionLenght = 0;
              _mTotalSchoolLenght = 0;
              _mTotalStateLenght = 0;
              _mRankBySchool = 0;
              _mRankByState = 0;
              _mRankByCountry = 0;
              _perCompare = 0;
              _mSubject = '';
              _isSubjectClickForRank = true;

              if (subjectList[index].subjectName == StringConstants.all) {
                _getSchoolNameForRanking('');
              } else {
                _getSchoolNameForRanking(subjectList[index].subjectName);
              }
            },
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsAttempts(int index) {
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
                    width: 60.0,
                    color: const Color(AppColors.primaryColor),
                  ),
                )
              ],
            ),
            onPressed: () {
              setStateTask(false);
              this.indexAttempts = index;
              _isSubjectClickForRank = false;
              _isSubjectClickForAttempts = true;

              if (categoryArray.length > 0) {
                categoryArray.clear();
              }

              if (listLinearAttempts.length > 0) {
                listLinearAttempts.clear();
              }

              if (colorArray.length > 0) {
                colorArray.clear();
              }

              if (seriesListAttempts.length > 0) {
                seriesListAttempts.clear();
              }

              if (subjectList[index].subjectName == StringConstants.all) {
                _getAttempts('');
              } else {
                _getAttempts(subjectList[index].subjectName);
              }
            },
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
  }

  Widget textWidget(double value) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            subjectList[index].subjectName,
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
            'Statictics',
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
            subjectList[indexRanking].subjectName,
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

  Widget textWidgetLastSession() {
    if (scoreLastSession != '' && questionList.length > 0) {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            alignment: Alignment.centerLeft,
            child: Text(
              'Score $scoreLastSession/10',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'novabold',
                fontSize: 18.0,
              ),
            ),
          ),
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
      return Container(
        child: Center(
          child: Text('Result Not Found'),
        ),
      );
    }
  }

  Widget textWidgetAttempts() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          alignment: Alignment.centerLeft,
          child: Text(
            subjectList[indexAttempts].subjectName + ' Attempts',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'novabold',
              fontSize: 18.0,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  height: 300.0,
                  child: Center(
                    child: _drawPieChart(),
                  ),
                ),
              ),
              Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    height: 300.0,
                    child: Center(
                      child: CustomScrollView(
                        slivers: <Widget>[
                          SliverFixedExtentList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                // To convert this infinite list to a list with three items,
                                // uncomment the following line:
                                // if (index > 3) return null;
                                return bodyWidgetAttempts(index);
                              },
                              // Or, uncomment the following line:
                              childCount: categoryArray.length,
                            ),
                            itemExtent: 40.0,
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        )
      ],
    );
  }

  Widget _drawLineChart() {
    if (seriesList.length != 0) {
      return new charts.LineChart(seriesList,
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

  Widget bodyWidgetLastSession(int index) {
    if (questionList.length > 0) {
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
                      questionList[index].questionKey,
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
                      questionList[index].answerText,
                      style: getTextStyleForLastSession(),
                    ),
                    Container(
                      width: 10,
                    ),
                    getIcon(index)
                  ],
                ))
          ],
        ),
      );
    } else {
      return new Container(
        child: Center(
          child: Text('Result Not Found'),
        ),
      );
    }
  }

  Widget getIcon(int index) {
    if (questionList[index].isCorrect) {
      return Icon(Icons.check, color: Colors.green);
    } else {
      return Icon(Icons.clear, color: Colors.red);
    }
  }

  Widget bodyWidgetAttempts(int index) {
    if (categoryArray.length > 0) {
      return Container(
          alignment: Alignment.centerLeft,
          child: Text(
            categoryArray[index],
            style: getTextStyleForAttempts(index),
          ));
    } else {
      return Container();
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
          _getTotalSession('');
          _getSchoolNameForRanking('');
          _getLastSessionAttempts();
          _getScoreOfLastSessionCompleted();
          _getAttempts('');
        } else {
          setStateTask(false);
        }
      }
    } catch (e) {
      setStateTask(false);
      print(e);
    }
  }

  // Get Total Session For Calculate Student Performance
  Future<void> _getTotalSession(String subject) async {
    _totalSessionLenght = 0;
    this.subject = subject;
    try {
      await studentLearnRateReference
          .child(userId)
          .once()
          .then((DataSnapshot snapshot) {
        _valueSession = snapshot.value;
        if (_valueSession != null) {
          for (final key in _valueSession.keys) {
            Map<dynamic, dynamic> map = _valueSession[key];
            if (subject == map['subject']) {
              _totalSessionLenght++;
            } else {
              _totalSessionLenght++;
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
    if (_totalSessionLenght != 0) {
      _calculatePerformanceTask(subject);
    } else {
      setStateTask(false);
    }
  }

  Future<void> _calculatePerformanceTask(String subject) async {
    List<SessionModel> listSession = new List();
    String lastDate = '';
    int freq = 0;

    try {
      studentLearnRateReference
          .child(userId)
          .orderByKey()
          .onChildAdded
          .listen((Event event) {
        _valueSession = event.snapshot.value;

        if (_valueSession != null) {
          if (_valueSession.containsKey('sessionDate')) {
            if (subject != '') {
              if (subject == _valueSession['subject']) {
                if (lastDate == '') {
                  lastDate = _valueSession['sessionDate'];
                  freq++;
                } else {
                  if (lastDate == _valueSession['sessionDate']) {
                    freq++;
                  } else {
                    freq = 0;
                    lastDate = _valueSession['sessionDate'];
                    freq++;
                  }
                }
                SessionModel sessionModel = new SessionModel(
                    _valueSession['difficultyLevel'],
                    _valueSession['score'],
                    freq);
                listSession.add(sessionModel);
              }
            } else {
              if (lastDate == '') {
                lastDate = _valueSession['sessionDate'];
                freq++;
              } else {
                if (lastDate == _valueSession['sessionDate']) {
                  freq++;
                } else {
                  freq = 0;
                  lastDate = _valueSession['sessionDate'];
                  freq++;
                }
              }

              SessionModel sessionModel = new SessionModel(
                  _valueSession['difficultyLevel'],
                  _valueSession['score'],
                  freq);
              listSession.add(sessionModel);
            }

            if (_totalSessionLenght == listSession.length) {
              print('LL UP>>' + _totalSessionLenght.toString());
              print('LL Down>>' + listSession.length.toString());
              calculatePerformance(listSession);
            }
          } else {
            setStateTask(false);
          }
        } else {
          setStateTask(false);
        }
      }).onError(errorHandle);
    } catch (e) {
      print('Error: $e');
      setStateTask(false);
    }
  }

  void errorHandle() {
    setStateTask(false);
  }

  void calculatePerformance(List<SessionModel> listSession) {
    listLinearPer.add(new LinearPerformance(0, 0.0));
    double recency = 0.0;
    int pos = 0;
    for (int i = 0; i < listSession.length; i++) {
      if (i > 2) {
        recency = double.parse(listSession[i].score) +
            double.parse(listSession[i - 1].score) +
            double.parse(listSession[i - 2].score);
        double finalRecency = recency / 3;
        per = finalRecency *
            listSession[i].frequency *
            double.parse(listSession[i].difficultyLevel);
      } else {
        pos++;
        recency = recency + double.parse(listSession[i].score);
        double finalRecency = recency / pos;
        per = finalRecency *
            listSession[i].frequency *
            double.parse(listSession[i].difficultyLevel);
        if (i == 2) {
          recency = 0.0;
          pos = 0;
        }
      }

      print('Performance is>>' + per.toString());
      listLinearPer.add(new LinearPerformance(i + 1, per));
      seriesList = _createPerformanceData();
      if (_isSubjectClickForPerformance) {
        _isSubjectClickForPerformance = false;
        setStateTask(false);
      }
    }
  }

  // Get School Name For Calculate Student Ranking...
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

//          print('CurrentUser_mDifficultyLevel>>>' + _mDifficultyLevel);
//          print('CurrentUser_mLastSeen>>>' + _mLastSeen);
//          print('CurrentUser_mDifference>>>' + _mDifference.toString());
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

//                  print('_mUserId School>>' + _mUserId);
//                  print('_mDifficultyLevel School>>>' + _mDifficultyLevel);
//                  print('_mLastSeen School>>>' + _mLastSeen);
//                  print('_mDifference School>>>' + _mDifference.toString());

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

//                  print('_mUserId State>>' + _mUserId);
//                  print('_mDifficultyLevel State>>>' + _mDifficultyLevel);
//                  print('_mLastSeen State>>>' + _mLastSeen);
//                  print('_mDifference State>>>' + _mDifference.toString());

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
          //print('Total Session Lenght>>$_mTotalSessionLenght');
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
              //print('_mDifficultyLevelU>>' + _mDifficultyLevel);
              calculatePerformanceForRank(isComingFrom, _mTotalSessionLenght);
            }
          } else {
            _mDifficultyLevel = _valueSession['difficultyLevel'];
            //print('_mDifficultyLevelD>>' + _mDifficultyLevel);
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
//      print(
//          'LL For School>>' + userRankingListWithSchoolName.length.toString());

      for (var userRankingModel in userRankingListWithSchoolName) {
        if (_perCompare == userRankingModel.performance) {
          _mRankBySchool =
              userRankingListWithSchoolName.indexOf(userRankingModel) + 1;
          //print('_mRankBySchool>>' + _mRankBySchool.toString());

          if (_isSubjectClickForRank && _mRankBySchool > 0) {
            //print('Enter Up');
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
      //print('LL For State>>' + userRankingListWithStateName.length.toString());

      for (var userRankingModel in userRankingListWithStateName) {
        if (_perCompare == userRankingModel.performance) {
          _mRankByState =
              userRankingListWithStateName.indexOf(userRankingModel) + 1;
          //print('_mRankByState>>' + _mRankByState.toString());

          if (_isSubjectClickForRank && _mRankByState > 0) {
            //print('Enter Down');
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
      //print('Here>>' + _perCompare.toString());
      setStateTask(false);
    }

    //print('Peformance For Rank>>' + _mPer.toString());

    if (_isRunFirstRun) {
      _isRunFirstRun = false;
      _compareStudentsWithSchoolName();
      _compareStudentsWithStateName();
    }
  }

  // Get Last Session Attempts Student
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
              _quizSession['quizType'],
              _quizSession['answerText']);
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  Future<void> _getLastSessionAttemptedQuestions(
      String grade,
      String subject,
      String category,
      String questionKey,
      String quizType,
      String answerText) async {
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
          AnsCatModel ansCatModel;
          if (answerText == snapshot.value['correctAnswer']) {
            ansCatModel = new AnsCatModel(snapshot.value['question'],
                snapshot.value['correctAnswer'], true);
          } else {
            ansCatModel = new AnsCatModel(snapshot.value['question'],
                snapshot.value['correctAnswer'], false);
          }

          if (questionList != null) {
            questionList.add(ansCatModel);
          }
        }
      });
    } catch (e) {
      setStateTask(false);
      print('Error: $e');
    }
  }

  // Get Score of Last Session Completed By Student
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

  // Get Attempts By Student
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

        //print('Total Attempts Lenght' + _mTotalAttempts.toString());
        if (categoryArray.length > 0) {
          categoryArray.sort((x, y) => x.length.compareTo(y.length));
          for (var cat in categoryArray) {
            //print(cat);
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
//    print('totalAttempts>>' + totalAttempts.toString());
//    print('catAttempts>>' + catAttempts.toString());
    double perAttempts = (totalAttempts * catAttempts) / 100;
//    print('perAttempts>>' + perAttempts.toString());
    color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt() << 0)
        .withOpacity(1.0);
    colorArray.add(color);
    listLinearAttempts.add(new LinearAttempts(catAttempts, perAttempts, color));
    seriesListAttempts = _createAttemptsPercentage();

    if (_isSubjectClickForAttempts) {
      _isSubjectClickForAttempts = false;
      setStateTask(false);
    }
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<LinearPerformance, int>> _createPerformanceData() {
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
          //colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (LinearAttempts sales, _) => sales.sessionAttempts,
          measureFn: (LinearAttempts sales, _) => sales.percentage,
          colorFn: (LinearAttempts sales, _) => sales.color,
          data: listLinearAttempts,
        )
      ];
    } else {
      return [];
    }
  }

  TextStyle getTextStyleForAttempts(int i) {
    if (colorArray.length > 0) {
      return new TextStyle(
          fontWeight: FontWeight.bold,
          color: colorArray[i],
          fontSize: 17.0,
          fontFamily: 'novabold');
    } else {
      return new TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 17.0,
          fontFamily: 'novabold');
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
  final charts.Color color;

  LinearAttempts(this.sessionAttempts, this.percentage, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
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
