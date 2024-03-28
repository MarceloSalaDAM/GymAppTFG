import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundTimer {
  Timer? _timer;
  int _millisecondsElapsed = 0;
  late StreamController<Map<String, dynamic>> _dataStreamController;

  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  BackgroundTimer() {
    _dataStreamController = StreamController.broadcast();
  }

  void start() async {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _millisecondsElapsed += 100;
      _sendDataToBackgroundService(_calculateTime());
    });
  }

  void stop() {
    _timer?.cancel();
    _millisecondsElapsed = 0; // Reinicia a cero
    _sendDataToBackgroundService(_calculateTime()); // Envía el estado actualizado
  }

  Map<String, dynamic> _calculateTime() {
    int hours = (_millisecondsElapsed ~/ 3600000); // Calcula las horas
    int minutes = (_millisecondsElapsed ~/ 60000) % 60;
    int seconds = (_millisecondsElapsed ~/ 1000) % 60;
    int milliseconds = _millisecondsElapsed % 1000;

    return {
      'hours': hours ?? 0, // Si hours es nulo, establecerlo como 0
      'minutes': minutes ?? 0, // Si minutes es nulo, establecerlo como 0
      'seconds': seconds ?? 0, // Si seconds es nulo, establecerlo como 0
      'milliseconds': milliseconds ?? 0, // Si milliseconds es nulo, establecerlo como 0
    };
  }



  void _sendDataToBackgroundService(Map<String, dynamic> data) {
    _dataStreamController.add(data);
  }

  void dispose() {
    _dataStreamController.close();
  }
}
