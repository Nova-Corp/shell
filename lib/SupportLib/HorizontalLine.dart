import 'package:flutter/material.dart';

class Drawhorizontalline extends CustomPainter {
      Paint _paint;
      bool reverse;
      double lineSize;

   Drawhorizontalline(this.reverse, this.lineSize) {
     _paint = Paint()
          ..color = Colors.black
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;
   }

  @override
  void paint(Canvas canvas, Size size) {
      if (reverse) {
         canvas.drawLine(Offset(-lineSize, 0.0), Offset(-10.0, 0.0), _paint);
      } else {
         canvas.drawLine(Offset(10.0, 0.0), Offset(lineSize, 0.0), _paint);
      }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
     return false;
  }
}