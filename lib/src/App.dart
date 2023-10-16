import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app_tfg/src/views/login_view.dart';
import 'package:gym_app_tfg/src/views/main_view.dart';
import 'package:gym_app_tfg/src/views/on_boarding.dart';
import 'package:gym_app_tfg/src/views/register_view.dart';
import 'package:gym_app_tfg/src/views/splash_view.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    /*Declaramos las rutas que va a seguir nuestra aplicación,
    la primera que entra es el SPLASH, si no se ha iniciado sesion
    anteriormente, nos lleva al LOGIN, si ya esta iniciada la sesión
    nos lleva al home directamente.
    Desde la pantalla LOGIN, podemos registrar un nuevo usuario y desde la
    pantalla de REGISTRO, nos lleva al ONBOARDING para completar el perfil.*/
    return MaterialApp(
     theme: ThemeData(
        textTheme: GoogleFonts.baiJamjureeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/Splash',
      routes: {
        '/Login': (context) => LoginViewApp(),
        '/Register': (context) => RegisterView(),
        '/Main': (context) => MainViewApp(),
        '/OnBoarding': (context) => OnBoardingView(),
        '/Splash': (context) => SplashView(),
      },
    );
  }
}
