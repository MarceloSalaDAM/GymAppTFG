import 'dart:async';

class TimerService {
  final StreamController<int> _timerController = StreamController.broadcast();
  Stream<int> get timerStream => _timerController.stream;
  late Timer _timer;
  late StreamController<int> _controller;
  late int _start;
  late bool _isRunning;

  TimerService() {
    _controller = StreamController<int>();
    _start = 0;
    _isRunning = false;
  }



  void start() {
    if (!_isRunning) {
      _timer = Timer.periodic(const Duration(milliseconds: 10), _tick);
      _isRunning = true;
    }
  }

  void stop() {
    if (_isRunning) {
      _timer.cancel();
      _isRunning = false;
    }
  }

  void reset() {
    stop();
    _start = 0;
    _controller.add(_start);
  }

  void _tick(Timer timer) {
    _start += 10;
    _controller.add(_start);
  }

  void dispose() {
    _controller.close();
  }
}
