import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom/input_text_1.dart';

class LoginViewApp extends StatelessWidget {
  const LoginViewApp({Key? key}) : super(key: key);

  Future<Image> loadBackgroundImage(BuildContext context) async {
    final image = Image.asset("assets/fondo.jpg");
    await precacheImage(image.image, context);
    return image;
  }

  void btnAceptarPressed(
      String emailAdress, String password, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAdress,
        password: password,
      );
      print("LOGEADO CON EXITO");

      Navigator.of(context).popAndPushNamed('/Main');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
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
      textoGuia: "Introducir usuario",
    );

    IPLogin iPass = IPLogin(
      titulo: "Contraseña",
      textoGuia: "Introducir contraseña",
      contra: true,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<Image>(
        future: loadBackgroundImage(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: const Color(0XFF0f7991),
            );
          } else if (snapshot.hasError) {
            return Container(
              color: Colors.red,
            );
          } else {
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: snapshot.data!.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(50, 150, 50, 60),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        color: const Color(0XFF0f7991),
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
                            height: 110,
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(125.0),
                            ),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Image.asset(
                                'assets/image.png',
                                width: 500,
                                height: 110,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          iUser,
                          const SizedBox(height: 10),
                          iPass,
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .popAndPushNamed('/Register');
                            },
                            child: const Text(
                              "No tengo cuenta",
                              style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  btnAceptarPressed(
                                    iUser.getText(),
                                    iPass.getText(),
                                    context,
                                  );
                                  print(
                                      "SESIÓN INICIADA CON----------->>>  ${iUser.getText()} ${iPass.getText()}");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
