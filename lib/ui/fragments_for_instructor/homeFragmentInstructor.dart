import 'dart:async';

import 'package:education_app/model/subjects_model.dart';
import 'package:education_app/ui/fragments_for_instructor/categoryInstructor.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomeFragmentInstructor extends StatefulWidget {
  const HomeFragmentInstructor();

  @override
  _HomeFragmentInstructorState createState() => _HomeFragmentInstructorState();
}

class _HomeFragmentInstructorState extends State<HomeFragmentInstructor> {
  final subjectReference = FirebaseDatabase.instance
      .reference()
      .child(StringConstants.instructor + 'Subjects');
  List<SubjectsModel> subjectList;
  StreamSubscription<Event> _onSubjectAdded;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    subjectReference.keepSynced(true);
    subjectList = new List();
    _onSubjectAdded = subjectReference.onChildAdded.listen(_onSubjectInstructorAdded);
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

  void _onSubjectInstructorAdded(Event event) {
    setState(() {
      subjectList.add(new SubjectsModel.fromSnapshot(event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new ProgressHUD(
        inAsyncCall: _saving, child: _buildWidget(), opacity: 0.0);
  }

  Widget _buildWidget() {
    return new Builder(
      builder: (context) => Container(
          padding: EdgeInsets.all(10.0),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  [headerWidget(StringConstants.select_any_que)],
                ),
              ),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5.0,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 5.0),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    // To convert this infinite list to a list with three items,
                    // uncomment the following line:
                    // if (index > 3) return null;
                    return bodyWidget(index);
                  },
                  // Or, uncomment the following line:
                  childCount: subjectList.length,
                ),
              ),
            ],
          )),
    );
  }

  Widget headerWidget(String text) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Text(
        text,
        style: getTextStyle(),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget bodyWidget(int index) {
    return FlatButton(
      onPressed: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
              maintainState: true,
              builder: (context) => new CategoryInstructor(
                  subjectName: subjectList[index].subjectName,
                  subIndex: index)),
        );
      },
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(5.0)),
      color: new HexColor(subjectList[index].color),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 8,
            child: Container(
              height: 50.0,
              width: 50.0,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      fit: BoxFit.contain,
                      image: new NetworkImage(subjectList[index].icon))),
            ),
          ),
          Expanded(
              flex: 2,
              child: Container(
                  color: Colors.black12,
                  child: Center(
                    child: Text(
                      '${subjectList[index].subjectName}',
                      style: getTextStyleForSubjects(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ))),
        ],
      ),
    );
  }

  void setStateTask(isTaskDone) {
    setState(() {
      _saving = isTaskDone;
    });
  }
}

TextStyle getTextStyle() {
  return new TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.black,
      fontSize: 16.0,
      fontFamily: 'novabold');
}

TextStyle getTextStyleForSubjects() {
  return new TextStyle(
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontSize: 15.0,
      fontFamily: 'novabold');
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
