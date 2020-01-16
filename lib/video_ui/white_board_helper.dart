import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget buildUploadingDialog() {
  return Container(
    alignment: Alignment.center,
    margin: EdgeInsets.all(30.0),
    child: Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 0.0,
      color: Colors.black54,
      child: Container(
        margin: EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: SpinKitCircle(color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Uploading please wait...',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
