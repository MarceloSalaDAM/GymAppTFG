import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../custom/input_text_1.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({Key? key}) : super(key: key);

  Future<Image> loadBackgroundImage(BuildContext context) async {
    final image = Image.asset("assets/fondo.jpg");
    await precacheImage(image.image, context);
    return image;
  }

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
      textoGuia: "Introducir e-mail",
      titulo: "E-mail",
    );
    IPLogin iContra = IPLogin(
      textoGuia: "Introducir contraseña",
      titulo: "Contraseña",
      contra: true,
    );
    IPLogin iContra2 = IPLogin(
      textoGuia: "Repetir contraseña",
      titulo: "Repetir contraseña",
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
                        mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(height: 5),
                          iUsuario,
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: iContra,
                          ),
                          iContra2,
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context)
                                      .popAndPushNamed('/Login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_back,
                                    size: 30, color: Colors.white),
                                // Añade el ícono de retroceso
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 1.0),
                                  child: Text(
                                    '', // Deja el texto vacío
                                    style: TextStyle(
                                      fontSize: 1.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (iContra.getText() == iContra2.getText()) {
                                    btnRegistroPressed(iUsuario.getText(),
                                        iContra.getText(), context);
                                    print(
                                        "USUARIO CREADO CORRECTAMENTE------>>> ${iUsuario.getText()} ${iContra.getText()}");
                                  } else {}
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
                                    'ACEPTAR',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
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
