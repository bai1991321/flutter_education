import 'package:flutter/material.dart';
import 'package:education_app/utils/constants.dart';

class Signature extends CustomPainter {
  List<Offset> points;

  Signature({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = whiteBoardBrushColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = whiteBoardBrushSize;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => true;
}
