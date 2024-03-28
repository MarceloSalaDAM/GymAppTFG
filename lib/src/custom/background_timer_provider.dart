import 'package:flutter/material.dart';
import 'package:gym_app_tfg/src/custom/timer.dart';

class BackgroundTimerProvider extends InheritedWidget {
  final BackgroundTimer backgroundTimer;

  BackgroundTimerProvider({
    required this.backgroundTimer,
    required Widget child,
  }) : super(child: child);

  static BackgroundTimerProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<BackgroundTimerProvider>();
  }

  @override
  bool updateShouldNotify(BackgroundTimerProvider oldWidget) {
    return backgroundTimer != oldWidget.backgroundTimer;
  }
}
