import 'package:egg_timer/colors_constants.dart';
import 'package:flutter/material.dart';
import 'dart:math' show pi;

class EggTimerKnob extends StatefulWidget {
  final rotationPercent;

  const EggTimerKnob({this.rotationPercent});

  @override
  _EggTimerKnobState createState() => _EggTimerKnobState();
}

class _EggTimerKnobState extends State<EggTimerKnob> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: ArrowPainter(rotationPercent: widget.rotationPercent),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [ColorsConstants.GRADIENT_TOP, ColorsConstants.GRADIENT_BOTTOM]),
            boxShadow: [
              BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(0.0, 1.0))
            ]),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: Color(0xFFDFDFDF), width: 1.5)),
          child: Center(
            child: Transform(
              transform: Matrix4.rotationZ(2 * pi * widget.rotationPercent),
              alignment: Alignment.center,
              child: Image.asset(
                  'assets/images/boiled-egg.png',
                  width: 50.0,
                  height: 50.0,
                  color: Colors.black),
            ),
          ),
        ),
      )
    ]);
  }
}

class ArrowPainter extends CustomPainter {
  final Paint dialArrowPaint;
  final double rotationPercent;

  ArrowPainter({this.rotationPercent}) : dialArrowPaint = Paint() {
    dialArrowPaint.color = Colors.black;
    dialArrowPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    final radius = size.height / 2;
    canvas.translate(radius, radius);
    canvas.rotate(2 * pi * this.rotationPercent);

    Path path = Path();
    path.moveTo(0.0, -radius - 10.0);
    path.lineTo(10.0, -radius + 5.0);
    path.lineTo(-10.0, -radius + 5.0);
    path.close();

    canvas.drawPath(path, dialArrowPaint);
    canvas.drawShadow(path, Colors.black, 3.0, false);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
