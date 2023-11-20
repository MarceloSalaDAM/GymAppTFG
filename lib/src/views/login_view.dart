import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom/input_text_1.dart';
import 'main_view.dart';

class LoginViewApp extends StatelessWidget {
  const LoginViewApp({Key? key}) : super(key: key);

  void btnAceptarPressed(
      String emailAdress, String password, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAdress,
        password: password,
      );
      print("LOGEADO CON EXITO");

      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const MainViewApp(),
        ));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Notifica al usuario que la actualización se realizó con éxito.
        print('No user found for that email');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('USUARIO O CONTRASEÑA INCORRECTOS'),
          duration: Duration(milliseconds: 4000),
          backgroundColor: Colors.red,
        ),
      );
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: double.maxFinite,
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
                height: 420,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 5.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(125.0),
                      ),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        // Ajusta la propiedad BoxFit.cover para cubrir el contenedor sin distorsionar la imagen.
                        child: Image.asset(
                          'assets/image.png',
                          width: 500,
                          height: 110,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),
                    iUser,
                    iPass,
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).popAndPushNamed('/Register');
                      },
                      child: Text(
                        "No tengo cuenta",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Espacio entre el texto y el botón
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                          height: 40,
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.white,
                          splashColor: Colors.white,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(3.0),
                              child: Icon(Icons.login_outlined),
                            ),
                          ),
                          onPressed: () {
                            btnAceptarPressed(
                              iUser.getText(),
                              iPass.getText(),
                              context,
                            );
                            print(
                                "SESIÓN INICIADA CON----------->>>  ${iUser.getText()} ${iPass.getText()}");
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
