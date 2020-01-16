import 'package:flutter/material.dart';

class SimpleTextView extends StatefulWidget {
  final String data;
  final String fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Color color;
  final double fontSize;

  SimpleTextView({
    Key key,
    this.data = '',
    this.fontFamily = 'nova',
    this.fontWeight = FontWeight.normal,
    this.fontStyle,
    this.color = Colors.white,
    this.fontSize = 15.0,
  }) : super(key: key);

  @override
  _SimpleTextViewState createState() => new _SimpleTextViewState();
}

class _SimpleTextViewState extends State<SimpleTextView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        widget.data,
        style: new TextStyle(
            fontFamily: widget.fontFamily,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            fontStyle: widget.fontStyle,
            color: widget.color),
      ),
    );
  }
}
