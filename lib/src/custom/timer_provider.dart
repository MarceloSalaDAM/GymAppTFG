import 'package:flutter/material.dart';
import '../detail_views/details_routine.dart';
import 'package:provider/provider.dart';

class TimerModel extends ChangeNotifier {
  bool _isTimerRunning = false;
  int _secondsElapsed = 0;

  bool get isTimerRunning => _isTimerRunning;

  int get secondsElapsed => _secondsElapsed;

  void startTimer() {
    _isTimerRunning = true;
    notifyListeners();
    backgroundTimer.start();
  }

  void stopTimer() {
    _isTimerRunning = false;
    _secondsElapsed = 0; // Reinicia a cero
    notifyListeners();
    backgroundTimer.stop(); // Aquí detienes el temporizador en segundo plano
  }

  void updateSecondsElapsed(int seconds) {
    _secondsElapsed = seconds;
    notifyListeners();
  }
}

final timerProvider = ChangeNotifierProvider<TimerModel>(
  create: (context) => TimerModel(),
);
