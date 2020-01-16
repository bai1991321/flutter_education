import 'package:flutter/material.dart';

class SimpleMaterialButton extends StatefulWidget {
  final Color backgroundColor;
  final Text buttonText;
  final Color textColor;
  final VoidCallback onPressed;

  SimpleMaterialButton(
      {Key key,
      this.backgroundColor,
      this.buttonText,
      this.textColor,
      this.onPressed})
      : super(key: key);

  _SimpleMaterialButtonState createState() => _SimpleMaterialButtonState();
}

class _SimpleMaterialButtonState extends State<SimpleMaterialButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: MaterialButton(
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
