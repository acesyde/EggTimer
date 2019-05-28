import 'package:egg_timer/colors_constants.dart';
import 'package:egg_timer/components/egg_timer.dart';
import 'package:egg_timer/components/egg_timer_knob.dart';
import 'package:flutter/material.dart';
import 'dart:math' show pi;

import 'package:fluttery/animations.dart';

class EggTimerDial extends StatefulWidget {
  final EggTimerState eggTimerState;
  final Duration currentTime;
  final Duration maxTime;
  final int ticksPerSection;
  final Function(Duration) onTimeSelected;
  final Function(Duration) onDialStopTurning;

  const EggTimerDial(
      {this.eggTimerState,
      this.currentTime = const Duration(minutes: 0),
      this.maxTime = const Duration(minutes: 35),
      this.ticksPerSection = 5,
      this.onTimeSelected,
      this.onDialStopTurning});

  @override
  _EggTimerDialState createState() => _EggTimerDialState();
}

class _EggTimerDialState extends State<EggTimerDial>
    with TickerProviderStateMixin {
  static const RESET_SPEED_PERCENT_PER_SECOND = 1.0;

  EggTimerState previousEggTimerState;
  double previousRotationPercent = 0.0;
  AnimationController resetToZeroController;
  Animation resettingAnimation;

  _rotationPercent() {
    return widget.currentTime.inSeconds / widget.maxTime.inSeconds;
  }

  @override
  void initState() {
    super.initState();

    resetToZeroController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    resetToZeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentTime.inSeconds == 0 &&
        previousEggTimerState != EggTimerState.ready) {
      resettingAnimation = Tween(begin: previousRotationPercent, end: 0.0)
          .animate(resetToZeroController)
            ..addListener(() => setState(() {}))
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                setState(() {
                  resettingAnimation = null;
                });
              }
            });
      resetToZeroController.duration = Duration(
          milliseconds:
              ((previousRotationPercent / RESET_SPEED_PERCENT_PER_SECOND) *
                      1000)
                  .round());

      resetToZeroController.forward(from: 0.0);
    }

    previousEggTimerState = widget.eggTimerState;
    previousRotationPercent = _rotationPercent();

    return DialTurnGestureDetector(
      currentTime: widget.currentTime,
      maxTime: widget.maxTime,
      onTimeSelected: widget.onTimeSelected,
      onDialStopTurning: widget.onDialStopTurning,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(left: 45.0, right: 45.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
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
              child: Stack(children: <Widget>[
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.all(55.0),
                  child: CustomPaint(
                    painter: TickPainter(
                        tickCount: widget.maxTime.inMinutes,
                        ticksPerSection: widget.ticksPerSection),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(65.0),
                    child: EggTimerKnob(
                      rotationPercent: resettingAnimation == null
                          ? _rotationPercent()
                          : resettingAnimation.value,
                    )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class DialTurnGestureDetector extends StatefulWidget {
  final child;
  final Duration maxTime;
  final Duration currentTime;
  final Function(Duration) onTimeSelected;
  final Function(Duration) onDialStopTurning;

  const DialTurnGestureDetector(
      {this.currentTime,
      this.maxTime,
      this.child,
      this.onTimeSelected,
      this.onDialStopTurning});

  @override
  _DialTurnGestureDetectorState createState() =>
      _DialTurnGestureDetectorState();
}

class _DialTurnGestureDetectorState extends State<DialTurnGestureDetector> {
  PolarCoord startDragCoord;
  Duration startDragTime;
  Duration selectedTime;

  _onRadialDragStart(PolarCoord coord) {
    startDragCoord = coord;
    startDragTime = widget.currentTime;
  }

  _onRadialDragUpdate(PolarCoord coord) {
    if (startDragCoord != null) {
      var angleDiff = coord.angle - startDragCoord.angle;
      angleDiff = angleDiff >= 0.0 ? angleDiff : angleDiff + (2 * pi);
      final anglePercent = angleDiff / (2 * pi);
      final timeDiffInSeconds =
          (anglePercent * widget.maxTime.inSeconds).round();
      selectedTime =
          Duration(seconds: startDragTime.inSeconds + timeDiffInSeconds);

      widget.onTimeSelected(selectedTime);
    }
  }

  _onRadialDragEnd() {
    widget.onDialStopTurning(selectedTime);
    startDragCoord = null;
    startDragTime = null;
    selectedTime = null;
  }

  @override
  Widget build(BuildContext context) {
    return RadialDragGestureDetector(
      onRadialDragStart: _onRadialDragStart,
      onRadialDragUpdate: _onRadialDragUpdate,
      onRadialDragEnd: _onRadialDragEnd,
      child: widget.child,
    );
  }
}

class TickPainter extends CustomPainter {
  final LONG_TICK = 14.0;
  final SHORT_TICK = 4.0;

  final tickCount;
  final ticksPerSection;
  final ticksInset;
  final tickPaint;
  final textPainter;
  final textStyle;

  TickPainter(
      {this.tickCount = 35, this.ticksPerSection = 5, this.ticksInset = 0.0})
      : tickPaint = Paint(),
        textPainter = TextPainter(
            textAlign: TextAlign.center, textDirection: TextDirection.ltr),
        textStyle = TextStyle(
            color: Colors.black, fontFamily: 'BebasNeue', fontSize: 20.0) {
    tickPaint.color = Colors.black;
    tickPaint.strokeWidth = 1.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    canvas.save();

    final radius = size.width / 2;
    for (var i = 0; i < tickCount; ++i) {
      final tickLength = i % ticksPerSection == 0 ? LONG_TICK : SHORT_TICK;

      canvas.drawLine(
          Offset(0.0, -radius), Offset(0.0, -radius - tickLength), tickPaint);

      if (i % ticksPerSection == 0) {
        canvas.save();
        canvas.translate(0.0, -(size.width / 2) - 30.0);
        textPainter.text = TextSpan(text: '$i', style: textStyle);

        textPainter.layout();

        final tickPercent = i / tickCount;
        var quadrant;

        if (tickPercent < 0.25) {
          quadrant = 1;
        } else if (tickPercent < 0.5) {
          quadrant = 4;
        } else if (tickPercent < 0.75) {
          quadrant = 3;
        } else {
          quadrant = 0;
        }

        switch (quadrant) {
          case 4:
            canvas.rotate(-pi / 2);
            break;
          case 2:
          case 3:
            canvas.rotate(pi / 2);
            break;
        }

        textPainter.paint(
            canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

        canvas.restore();
      }

      canvas.rotate(2 * pi / tickCount);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
