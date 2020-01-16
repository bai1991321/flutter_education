import 'package:flutter/material.dart';

import '../utils/image_assets.dart';

class SimpleRoundIconButton extends StatelessWidget {
  final Color backgroundColor;
  final Text buttonText;
  final Color textColor;
  final Icon icon;
  final Image image;
  final Color iconColor;
  final Alignment iconAlignment;
  final VoidCallback onPressed;
  final bool isIcon;

  SimpleRoundIconButton(
      {Key key,
      this.backgroundColor = Colors.redAccent,
      this.buttonText = const Text("REQUIRED TEXT"),
      this.textColor = Colors.white,
      this.icon = const Icon(Icons.email),
      this.image = const Image(image: AssetImage(ImageAssets.flutterLogo)),
      this.iconColor,
      this.iconAlignment = Alignment.centerLeft,
      this.isIcon = const bool.fromEnvironment('isIcon', defaultValue: true),
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15.0),
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: MaterialButton(
                splashColor: this.backgroundColor,
                color: this.backgroundColor,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        height: 50.0,
                        child: isReturnIcon(),
                      ),
                    ),
                    Expanded(
                        flex: 7,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: buttonText,
                        ))
                  ],
                ),
                onPressed: () => onPressed()),
          ),
        ],
      ),
    );
  }

  Widget isReturnIcon() {
    if (isIcon == false) {
      return Center(
        child: image,
      );
    }
    return Center(
      child: Icon(
        icon.icon,
        size: 20.0,
        color: Colors.white,
      ),
    );
  }
}
