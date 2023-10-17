import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../custom/input_text_1.dart';
import 'main_view.dart';

class LoginViewApp extends StatelessWidget {
  //Vista para el logeo a la aplicacion
  const LoginViewApp({Key? key}) : super(key: key);

  /*Con esta funcion conseguimos que se logee el usuario
  SI coincide con un usuario ya creado en el firebase*/
  void btnAceptarPressed(
      String emailAdress, String password, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAdress,
        password: password,
      );
      print("LOGEADO CON EXITO");

      // Agregar un retraso de 2 segundos antes de navegar a la pantalla principal
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const MainViewApp(),
        ));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not found') {
        print('No user found for that email');
      } else if (e.code == 'wrong password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    IPLogin iUser = IPLogin(
      titulo: "Usuario",
    );

    IPLogin iPass = IPLogin(
      titulo: "Contraseña",
      contra: true,
    );
/*
    EL BOTON NO LO HE METIDO EN UNA CARPETA CUSTOM PORQUE SOLO LO VOY A UTILIZAR EN ESTA VENTANA,
    POR LO TANTO LO HE CREADO AQUI MISMO*/
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Container(
          width: double.maxFinite, // Ancho del contenedor
          height: double.maxFinite,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/fondo.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Center(
            child: Container(

              margin: const EdgeInsets.fromLTRB(50, 150, 50, 60),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              width: 500,
              height: 450,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  // Cambia estos colores según tus preferencias
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(),
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black, // Color de la sombra
                    blurRadius: 5.0, // Radio de desenfoque de la sombra
                    offset: Offset(
                        0, 4), // Desplazamiento de la sombra (eje X, eje Y)
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // Evita que la columna se expanda más allá del contenido
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                  ),
                  const SizedBox(height: 5),
                  // Agrega un espacio entre la imagen y los campos de texto
                  iUser,
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    // Agrega espacio en la parte inferior
                    child: iPass,
                  ),

                  const SizedBox(height: 30),
                  // Agrega un espacio entre los campos de texto y el botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              7.0), // Cambia el radio de las esquinas a 10.0
                        ),
                        padding: const EdgeInsets.all(8.0),
                        textColor: Colors.white,
                        splashColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("REGISTRO"),
                          ),
                        ),
                        // ),
                        onPressed: () {
                          Navigator.of(context).popAndPushNamed('/Register');
                        },
                      ),
                      MaterialButton(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              7.0), // Cambia el radio de las esquinas a 10.0
                        ),
                        padding: const EdgeInsets.all(8.0),
                        textColor: Colors.white,
                        splashColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("ENTRAR"),
                          ),
                        ),
                        onPressed: () {
                          btnAceptarPressed(
                            iUser.getText(),
                            iPass.getText(),
                            context,
                          );
                          print("SESIÓN INICIADA CON----------->>>  ${iUser.getText()} ${iPass.getText()}");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
