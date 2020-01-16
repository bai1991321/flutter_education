import 'package:education_app/ui/fragments_for_student/categoryFragmentStudent.dart';
import 'package:education_app/ui/fragments_for_student/quizFragmentStudent.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/progress_hud.dart';
import 'package:education_app/utils/string_constants.dart';
import 'package:flutter/material.dart';

class OptionFragmentStudent extends StatefulWidget {
  final String subjectName;
  final int subIndex;
  final VoidCallback openSelectedItem;

  OptionFragmentStudent(
      {Key key, this.subjectName, this.subIndex, this.openSelectedItem})
      : super(key: key);

  @override
  _OptionFragmentStudentState createState() => _OptionFragmentStudentState();
}

class _OptionFragmentStudentState extends State<OptionFragmentStudent> {
  bool _saving = false;

  BuildContext context;

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
          padding: EdgeInsets.all(10.0), child: Center(child: bodyWidget())),
    );
  }

  Widget bodyWidget() {
    if(widget.subjectName != 'Math'){
      return Container(
        child: Center(
          child: Text('Coming Soon...'),
        ),
      );
    }else{
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                    maintainState: true,
                    builder: (context) => new CategoryStudent(
                        subjectName: widget.subjectName,
                        subIndex: widget.subIndex,
                        closeOptionWidget: _closeOptionWidget)),
              );
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0)),
            color: Colors.red,
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  //flex: 8,
                    child: Center(
                      child: Text(
                        StringConstants.choose_from_category,
                        style: getTextStyleForCategory(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    )),
              ],
            ),
          ),
          Divider(
            height: 20.0,
          ),
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                    maintainState: true,
                    builder: (context) => new QuizScreenStudent(
                      subjectName: widget.subjectName,
                      catName: '',
                      closeCatWidget : _closeOptionWidget,
                    )),
              );
            },
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0)),
            color: Colors.blue,
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  //flex: 8,
                    child: Center(
                      child: Text(
                        StringConstants.goes_anywhere,
                        style: getTextStyleForCategory(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    )),
              ],
            ),
          )
        ],
      );
    }
  }

  void _closeOptionWidget() {
    Navigator.pop(context);
    widget.openSelectedItem();
  }

  TextStyle getTextStyleForCategory() {
    return new TextStyle(
        fontWeight: FontWeight.normal,
        color: Colors.white,
        fontSize: 22.0,
        fontFamily: 'nova-bold');
  }
}
