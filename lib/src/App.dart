import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app_tfg/src/firebase_objects/rutinas_firebase.dart';
import 'package:gym_app_tfg/src/detail_views/create_new_rutine.dart';
import 'package:gym_app_tfg/src/detail_views/details_profile_view.dart';
import 'package:gym_app_tfg/src/detail_views/details_routine.dart';
import 'package:gym_app_tfg/src/list_views/exercise_list_view.dart';
import 'package:gym_app_tfg/src/list_views/list_routines.dart';
import 'package:gym_app_tfg/src/login_views/login_view.dart';
import 'package:gym_app_tfg/src/detail_views/main_view.dart';
import 'package:gym_app_tfg/src/login_views/on_boarding.dart';
import 'package:gym_app_tfg/src/login_views/register_view.dart';
import 'package:gym_app_tfg/src/login_views/splash_view.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Bloquea la orientación en posición vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.radioCanadaTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/Splash',
      routes: {
        '/Login': (context) => LoginViewApp(),
        '/Register': (context) => RegisterView(),
        '/Main': (context) => const MainViewApp(),
        '/OnBoarding': (context) => const OnBoardingView(),
        '/Splash': (context) => SplashView(),
        '/DetailsProfile': (context) => const DetailsProfileView(),
        '/ExerciseList': (context) => ExerciseListScreen(ejercicios: []),
        '/CreateRoutine': (context) => CrearRutinaView(ejercicios: []),
        '/ListRoutine': (context) => RutinasUsuarioView(),
        '/DetailsRoutine': (context) => DetallesRutinaView(
              rutina: Rutina(id: '', dias: {}),
            ),
      },
    );
  }
}
