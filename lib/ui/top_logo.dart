import 'package:flutter/material.dart';

import '../utils/image_assets.dart';

class TopLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 10.0),
      child: new Image(
        image: AssetImage(ImageAssets.flutterLogo),
        height: 160.0,
        width: 160.0,
      ),
    );
  }
}
