import 'package:flutter/material.dart';

class SimpleRoundButton extends StatefulWidget {
  final Color backgroundColor;
  final Text buttonText;
  final Color textColor;
  final VoidCallback onPressed;

  SimpleRoundButton(
      {Key key,
      this.backgroundColor,
      this.buttonText,
      this.textColor,
      this.onPressed})
      : super(key: key);

  _SimpleRoundButtonState createState() => _SimpleRoundButtonState();
}

class _SimpleRoundButtonState extends State<SimpleRoundButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15.0),
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: FlatButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(2.0)),
              splashColor: widget.backgroundColor,
              color: widget.backgroundColor,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: widget.buttonText,
                  ),
                ],
              ),
              onPressed: () => widget.onPressed(),
              padding: const EdgeInsets.all(10.0),
            ),
          ),
        ],
      ),
    );
  }
}
