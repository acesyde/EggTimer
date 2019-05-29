import 'package:egg_timer/components/egg_timer.dart';
import 'package:egg_timer/components/egg_timer_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class EggTimerControls extends StatefulWidget {
  final EggTimerState eggTimerState;
  final Function() onPause;
  final Function() onResume;
  final Function() onRestart;
  final Function() onReset;

  const EggTimerControls(
      {this.eggTimerState,
      this.onPause,
      this.onResume,
      this.onRestart,
      this.onReset});

  @override
  _EggTimerControlsState createState() => _EggTimerControlsState();
}

class _EggTimerControlsState extends State<EggTimerControls>
    with TickerProviderStateMixin {
  AnimationController pauseResumeSlideController;
  AnimationController restartResetFadeController;

  @override
  void initState() {
    super.initState();

    pauseResumeSlideController =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this)
          ..addListener(() => setState(() {}));

    pauseResumeSlideController.value = 1.0;

    restartResetFadeController =
        AnimationController(duration: Duration(milliseconds: 150), vsync: this)
          ..addListener(() => setState(() {}));

    restartResetFadeController.value = 1.0;
  }

  @override
  void dispose() {
    pauseResumeSlideController.dispose();
    restartResetFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.eggTimerState) {      
      case EggTimerState.ready:
        pauseResumeSlideController.forward();
        restartResetFadeController.forward();
        break;
      case EggTimerState.running:
        pauseResumeSlideController.reverse();
        restartResetFadeController.forward();
        break;
      case EggTimerState.paused:
        pauseResumeSlideController.reverse();
        restartResetFadeController.reverse();
        break;
    }

    return Column(
      children: <Widget>[
        Opacity(
          opacity: 1.0 - restartResetFadeController.value,
          child: Row(
            children: <Widget>[
              EggTimerButton(
                backgroundColor: Colors.transparent,
                iconData: Icons.refresh,
                text: FlutterI18n.translate(context, 'button_restart'),
                onPressed: widget.onRestart,
              ),
              Expanded(
                child: Container(),
              ),
              EggTimerButton(
                backgroundColor: Colors.transparent,
                iconData: Icons.arrow_back,
                text: FlutterI18n.translate(context, 'button_reset'),
                onPressed: widget.onReset,
              )
            ],
          ),
        ),
        Transform(
          transform: Matrix4.translationValues(
              0.0, 100.0 * pauseResumeSlideController.value, 0.0),
          child: EggTimerButton(
            backgroundColor: Colors.white,
            iconData: widget.eggTimerState == EggTimerState.running
                ? Icons.pause
                : Icons.play_arrow,
            text: widget.eggTimerState == EggTimerState.running
                ? FlutterI18n.translate(context, 'button_pause')
                : FlutterI18n.translate(context, 'button_resume'),
            onPressed: widget.eggTimerState == EggTimerState.running
                ? widget.onPause
                : widget.onResume,
          ),
        )
      ],
    );
  }
}
