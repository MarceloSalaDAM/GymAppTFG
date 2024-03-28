import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gym_app_tfg/src/App.dart';
import 'package:gym_app_tfg/src/custom/timer_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider<TimerModel>(
      create: (context) => TimerModel(), // Crea una instancia de TimerModel
      child: App(), // Envuelve tu aplicación con ChangeNotifierProvider
    ),
  );
}
