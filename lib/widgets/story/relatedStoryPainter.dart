import 'package:flutter/material.dart';

class RelatedStoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Color.fromRGBO(0, 7, 188, 1)
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 3.0;
    double padding = size.height - 28;
    Offset topP1 = Offset(0, 14);
    Offset topP2 = Offset(0, 0);
    Offset topP3 = Offset(size.width, 0);
    Offset topP4 = Offset(size.width, 14);
    Offset bottomP1 = Offset(0, 14 + padding);
    Offset bottomP2 = Offset(0, size.height);
    Offset bottomP3 = Offset(size.width, size.height);
    Offset bottomP4 = Offset(size.width, 14 + padding);

    canvas.drawLine(topP1, topP2, paint);
    canvas.drawLine(topP2, topP3, paint);
    canvas.drawLine(topP3, topP4, paint);
    canvas.drawLine(bottomP1, bottomP2, paint);
    canvas.drawLine(bottomP2, bottomP3, paint);
    canvas.drawLine(bottomP3, bottomP4, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
