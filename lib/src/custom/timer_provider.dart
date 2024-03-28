import 'package:flutter/material.dart';
import '../detail_views/details_routine.dart';
import 'package:provider/provider.dart';

class TimerModel extends ChangeNotifier {
  bool _isTimerRunning = false;
  int _millisecondsElapsed = 0; // Nuevo campo para los milisegundos

  bool get isTimerRunning => _isTimerRunning;
  int get millisecondsElapsed => _millisecondsElapsed; // Getter para los milisegundos

  void startTimer() {
    _isTimerRunning = true;
    notifyListeners();
    backgroundTimer.start();
  }

  void stopTimer() {
    _isTimerRunning = false;
    _millisecondsElapsed = 0; // Reinicia a cero
    notifyListeners();
    backgroundTimer.stop();
  }

  void updateElapsed(int milliseconds) {
    _millisecondsElapsed = milliseconds; // Actualiza los milisegundos
    notifyListeners();
  }
}

final timerProvider = ChangeNotifierProvider<TimerModel>(
  create: (context) => TimerModel(),
);
