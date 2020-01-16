import 'dart:async';

import 'package:education_app/model/subjects_model.dart';
import 'package:education_app/ui/fragments_for_student/quizFragmentStudent.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CategoryStudent extends StatefulWidget {
  final String subjectName;
  final int subIndex;
  final VoidCallback closeOptionWidget;

  CategoryStudent(
      {Key key, this.subjectName, this.subIndex, this.closeOptionWidget})
      : super(key: key);

  @override
  _CategoryStudentState createState() => _CategoryStudentState();
}

class _CategoryStudentState extends State<CategoryStudent> {
  List<CategoryModel> categoryList;
  StreamSubscription<Event> _onCategoryAdded;
  bool _saving = false;
  BuildContext context;

  @override
  void initState() {
    super.initState();
    final catReference = FirebaseDatabase.instance
        .reference()
        .child(StringConstants.student + 'Subjects')
        .child(widget.subIndex.toString())
        .child(widget.subjectName + StringConstants.category);
    categoryList = new List();
    _onCategoryAdded = catReference.onChildAdded.listen(_onCategoriesAdded);
  }

  @override
  void dispose() {
    try {
      _onCategoryAdded.cancel();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  void _onCategoriesAdded(Event event) {
    setState(() {
      categoryList.add(new CategoryModel.fromSnapshot(event.snapshot));
    });
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
          widget.subjectName,
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
    return new Builder(
      builder: (context) => Container(
          padding: EdgeInsets.all(10.0),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverFixedExtentList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    // To convert this infinite list to a list with three items,
                    // uncomment the following line:
                    // if (index > 3) return null;
                    return bodyWidget(index);
                  },
                  // Or, uncomment the following line:
                  childCount: categoryList.length,
                ),
                itemExtent: 90.0,
              ),
            ],
          )),
    );
  }

  Widget bodyWidget(int index) {
    return Column(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  maintainState: true,
                  builder: (context) => new QuizScreenStudent(
                        subjectName: widget.subjectName,
                        catName: categoryList[index].categoryName,
                        closeCatWidget: _closeCatWidget,
                      )),
            );
          },
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0)),
          color: new HexColor(categoryList[index].color),
          padding: EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 8,
                  child: Container(
                    child: Text(
                      '${categoryList[index].categoryName}',
                      style: getTextStyleForCategory(),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                    ),
                  )),
              Expanded(
                flex: 2,
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.contain,
                          image: new NetworkImage(categoryList[index].icon))),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  TextStyle getTextStyleForCategory() {
    return new TextStyle(
        fontWeight: FontWeight.normal,
        color: Colors.white,
        fontSize: 22.0,
        fontFamily: 'nova-bold');
  }

  void _closeCatWidget() {
    Navigator.pop(context);
    widget.closeOptionWidget();
  }
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
