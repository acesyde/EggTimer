import 'dart:async';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class EggTimer {
  final Duration maxTime;
  final Function onTimerUpdate;
  final Stopwatch stopwatch = Stopwatch();
  Duration _currentTime = const Duration(seconds: 0);
  Duration lastStartTime = const Duration(seconds: 0);
  EggTimerState state = EggTimerState.ready;

  EggTimer({this.maxTime, this.onTimerUpdate});

  get currentTime {
    return _currentTime;
  }

  set currentTime(newTime) {
    if (state == EggTimerState.ready) {
      _currentTime = newTime;
      lastStartTime = currentTime;
    }
  }

  resume() {
    if (state != EggTimerState.running) {
      if (state == EggTimerState.ready) {
        _currentTime = _roundToTheNearestMinute(_currentTime);
        lastStartTime = _currentTime;
      }

      state = EggTimerState.running;
      stopwatch.start();

      _tick();
    }
  }

  pause() {
    if (state == EggTimerState.running) {
      state = EggTimerState.paused;
      stopwatch.stop();

      if (null != onTimerUpdate) {
        onTimerUpdate();
      }
    }
  }

  reset() {
    if (state == EggTimerState.paused) {
      state = EggTimerState.ready;
      _currentTime = const Duration(seconds: 0);
      lastStartTime = _currentTime;
      stopwatch.reset();
    }
  }

  restart() {
    if (state == EggTimerState.paused) {
      state = EggTimerState.running;
      _currentTime = lastStartTime;
      stopwatch.reset();
      stopwatch.start();

      _tick();
    }
  }

  _roundToTheNearestMinute(Duration duration) {
    return Duration(
      minutes: (duration.inSeconds / 60).round()
    );
  }

  _tick() async {
    _currentTime = lastStartTime - stopwatch.elapsed;

    if (_currentTime.inSeconds > 0) {
      Timer(const Duration(seconds: 1), _tick);
    } else {
      state = EggTimerState.ready;
      await FlutterRingtonePlayer.playAlarm(
        volume: 1.0,
        looping: false
      );
    }

    if (null != onTimerUpdate) {
      onTimerUpdate();
    }
  }
}

enum EggTimerState { ready, running, paused }
