import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundTimer {
  Timer? _timer;
  int _secondsElapsed = 0;
  late StreamController<Map<String, dynamic>> _dataStreamController;

  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  BackgroundTimer() {
    _dataStreamController = StreamController.broadcast();
  }

  void start() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      _sendDataToBackgroundService({'secondsElapsed': _secondsElapsed});
    });
  }

  void stop() {
    _timer?.cancel();
    _secondsElapsed = 0; // Reinicia a cero
    _sendDataToBackgroundService({'secondsElapsed': _secondsElapsed}); // Envía el estado actualizado
  }


  void _sendDataToBackgroundService(Map<String, dynamic> data) {
    _dataStreamController.add(data);
  }

  void dispose() {
    _dataStreamController.close();
  }
}
