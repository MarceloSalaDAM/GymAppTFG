import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../custom/input_text_1.dart';

class RegisterView extends StatelessWidget {
  //Vista para el registro de usuarios de la aplicación
  RegisterView({Key? key}) : super(key: key);

  //Con esta función creamos un usuario y este es añadido al firebase
  void btnRegistroPressed(
      String emailAdress, String password, BuildContext context) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAdress,
        password: password,
      );
      Navigator.of(context).popAndPushNamed('/OnBoarding');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {}
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    IPLogin iUsuario = IPLogin(
      textoGuia: "Introducir usuario",
      titulo: "E-MAIL",
    );
    IPLogin iContra = IPLogin(
      textoGuia: "Introducir contraseña",
      titulo: "CONTRASEÑA",
      contra: true,
    );
    IPLogin iContra2 = IPLogin(
      textoGuia: "Repetir contraseña",
      titulo: "REPETIR CONTRASEÑA ",
      contra: true,
    );

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
              margin: EdgeInsets.fromLTRB(50, 150, 50, 60),
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.green],
                  // Cambia estos colores según tus preferencias
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(),
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
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
                  SizedBox(height: 5),
                  // Agrega un espacio entre la imagen y los campos de texto
                  iUsuario,
                  SizedBox(height: 15),
                  // Agrega un espacio entre los campos de texto
                  iContra,
                  iContra2,
                  SizedBox(height: 20),
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
                    padding: EdgeInsets.all(8.0),
                    textColor: Colors.white,
                    splashColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("CREAR"),
                      ),
                    ),
                        onPressed: () {
                          if (iContra.getText() == iContra2.getText()) {
                            btnRegistroPressed(
                                iUsuario.getText(), iContra.getText(), context);
                            print("USUARIO CREADO CORRECTAMENTE------>>>" +
                                " " +
                                iUsuario.getText() +
                                " " +
                                iContra.getText());
                          } else {}
                        },
                      ),
                      MaterialButton(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              7.0), // Cambia el radio de las esquinas a 10.0
                        ),
                        padding: EdgeInsets.all(8.0),
                        textColor: Colors.white,
                        splashColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("CANCELAR"),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).popAndPushNamed('/Login');
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
