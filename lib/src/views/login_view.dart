import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom/InputText.dart';

class LoginViewApp extends StatelessWidget {
  //Vista para el logeo a la aplicacion
  LoginViewApp({Key? key}) : super(key: key);

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
      Navigator.of(context).popAndPushNamed('/Home');
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
    IPExamen iUser = IPExamen(
      titulo: "EMAIL",
      textoGuia: "Introducir su email",
    );

    IPExamen iPass = IPExamen(
      titulo: "PASSWORD",
      textoGuia: "Introducir su clave",
      contra: true,
    );
/*
    EL BOTON NO LO HE METIDO EN UNA CARPETA CUSTOM PORQUE SOLO LO VOY A UTILIZAR EN ESTA VENTANA,
    POR LO TANTO LO HE CREADO AQUI MISMO*/
    return Scaffold(
      body: Center(
        child: Container(
            margin: EdgeInsets.fromLTRB(50, 160, 50, 0),
            padding: EdgeInsets.fromLTRB(20, 100, 20, 50),
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.lightGreenAccent],
                // Colores del gradiente
                begin: Alignment.topCenter,
                // Punto de inicio del gradiente
                end: Alignment.bottomCenter, // Punto de fin del gradiente
              ),
              border: Border.all(),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Color de la sombra
                  blurRadius: 5.0, // Radio de desenfoque de la sombra
                  offset: Offset(
                      0, 3), // Desplazamiento de la sombra (eje X, eje Y)
                ),
              ],
            ),
            child: Column(
              children: [
                iUser,
                iPass,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      padding: EdgeInsets.all(8.0),
                      textColor: Colors.black,
                      splashColor: Colors.teal,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          /*image: DecorationImage(
                            image: AssetImage('assets/cr7.png'),
                            fit: BoxFit.scaleDown),*/
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("ENTRAR"),
                        ),
                      ),
                      // ),
                      onPressed: () {
                        btnAceptarPressed(
                            iUser.getText(), iPass.getText(), context);
                        print("SESION INICIADA CON----------->>> " +
                            " " +
                            iUser.getText() +
                            " " +
                            iPass.getText());
                      },
                    ),
                  ],
                )
              ],
            )),
      ),
      backgroundColor: Colors.white70
      ,
    );
  }
}
