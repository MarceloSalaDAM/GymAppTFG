import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app_tfg/src/detail_views/details_routine_prefabricated.dart';
import 'package:gym_app_tfg/src/firebase_objects/rutinas_firebase.dart';
import 'package:gym_app_tfg/src/create_views/create_new_rutine.dart';
import 'package:gym_app_tfg/src/detail_views/details_profile_view.dart';
import 'package:gym_app_tfg/src/detail_views/details_routine.dart';
import 'package:gym_app_tfg/src/firebase_objects/rutinas_predeterminadas_firebase.dart';
import 'package:gym_app_tfg/src/list_views/exercise_list_view.dart';
import 'package:gym_app_tfg/src/list_views/list_routines.dart';
import 'package:gym_app_tfg/src/login_views/login_view.dart';
import 'package:gym_app_tfg/src/detail_views/main_view.dart';
import 'package:gym_app_tfg/src/login_views/on_boarding.dart';
import 'package:gym_app_tfg/src/login_views/register_view.dart';
import 'package:gym_app_tfg/src/login_views/splash_view.dart';
import 'create_views/add_routine_view.dart';
import 'create_views/edit_routine.dart';
import 'custom/background_timer_provider.dart';
import 'custom/timer.dart';
import 'detail_views/objetivos_view.dart';
import 'detail_views/stats_view.dart';
import 'list_views/list_routines_pred.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  FirebaseFirestore db = FirebaseFirestore.instance;

  String nivelSeleccionadoGlobal =
      "Principiante"; // Inicializa con el valor predeterminado

  String obtenerNivelSeleccionado() {
    return nivelSeleccionadoGlobal;
  }

  @override
  Widget build(BuildContext context) {
    final BackgroundTimer backgroundTimer = BackgroundTimer();
    // Bloquea la orientación en posición vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return BackgroundTimerProvider(
      // Envuelve tu MaterialApp con BackgroundTimerProvider
      backgroundTimer: backgroundTimer,
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.radioCanadaTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        initialRoute: '/Splash',
        routes: {
          '/Login': (context) => const LoginViewApp(),
          '/Register': (context) => const RegisterView(),
          '/Main': (context) => const MainViewApp(),
          '/OnBoarding': (context) => const OnBoardingView(),
          '/Splash': (context) => const SplashView(),
          '/DetailsProfile': (context) => const DetailsProfileView(),
          '/Stats': (context) => StatisticsView(),
          '/ExerciseList': (context) =>
              const ExerciseListScreen(ejercicios: []),
          '/CreateRoutine': (context) => const CrearRutinaView(ejercicios: []),
          '/ListRoutine': (context) => const RutinasUsuarioView(),
          '/DetailsRoutine': (context) => DetallesRutinaView(
                rutina: Rutina(id: '', dias: {}),
              ),
          '/DetailsRoutinePred': (context) {
            String nivelSeleccionado = obtenerNivelSeleccionado();
            return DetallesRutinaPredeterminadaView(
              rutinaPred: RutinaPredeterminada(idPred: '', diasPred: {}),
              nivelSeleccionado: nivelSeleccionado,
            );
          },
          '/AddRoutinePred': (context) => SelectTrainingLevelView(),
          '/EditRoutine': (context) => EjerciciosDiaView(
                dia: '',
                ejerciciosDia: {}, rutinaId: '',
              ),
          '/DetailsObjetivos': (context) => ObjetivosGeneralesScreen(),
          '/ListRoutinePred': (context) => const RutinasPredView(
                nivelSeleccionado: '',
              ),
        },
      ),
    );
  }
}
