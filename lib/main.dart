import 'package:egg_timer/colors_constants.dart';
import 'package:egg_timer/components/egg_timer.dart';
import 'package:egg_timer/components/egg_timer_controls.dart';
import 'package:egg_timer/components/egg_timer_dial.dart';
import 'package:egg_timer/components/egg_timer_time_display.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyEggTimerApp());

class MyEggTimerApp extends StatefulWidget {
  @override
  _MyEggTimerAppState createState() => _MyEggTimerAppState();
}

class _MyEggTimerAppState extends State<MyEggTimerApp> {
  EggTimer eggTimer;

  _MyEggTimerAppState() {
    eggTimer =
        EggTimer(maxTime: Duration(minutes: 35), onTimerUpdate: _onTimerUpdate);
  }

  _onTimeSelected(Duration newTime) {
    setState(() {
      eggTimer.currentTime = newTime;
    });
  }

  _onDialStopTurning(Duration newTime) {
    setState(() {
      eggTimer.currentTime = newTime;
      eggTimer.resume();
    });
  }

  _onTimerUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          FlutterI18nDelegate(
            useCountryCode: false,
            fallbackFile: "en.json",
            path: "assets/locales"
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('fr'),
          const Locale('en'),
        ],
        title: 'Egg Timer',
        theme: ThemeData(fontFamily: "BebasNeue"),
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  ColorsConstants.GRADIENT_TOP,
                  ColorsConstants.GRADIENT_BOTTOM
                ])),
            child: Center(
              child: Column(
                children: <Widget>[
                  EggTimerTimeDisplay(
                    eggTimerState: eggTimer.state,
                    selectionTime: eggTimer.lastStartTime,
                    countdownTime: eggTimer.currentTime,
                  ),
                  EggTimerDial(
                      eggTimerState: eggTimer.state,
                      currentTime: eggTimer.currentTime,
                      maxTime: eggTimer.maxTime,
                      ticksPerSection: 5,
                      onTimeSelected: _onTimeSelected,
                      onDialStopTurning: _onDialStopTurning),
                  Expanded(
                    child: Container(),
                  ),
                  EggTimerControls(
                    eggTimerState: eggTimer.state,
                    onPause: () {
                      setState(() => eggTimer.pause());
                    },
                    onResume: () {
                      setState(() => eggTimer.resume());
                    },
                    onReset: () {
                      setState(() => eggTimer.reset());
                    },
                    onRestart: () {
                      setState(() => eggTimer.restart());
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
