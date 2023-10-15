import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_app_tfg/src/firebase_objects/usuarios_firebase.dart';

import '../custom/InputText.dart';

class OnBoardingView extends StatefulWidget {
  // Vista para la cración del perfil una vez ha sido registrado
  OnBoardingView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OnBoardingViewState();
  }
}

class _OnBoardingViewState extends State<OnBoardingView> {
  var txt = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkExistingProfile();
  }

  //Comprobación de la existencia del perfil
  void checkExistingProfile() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    final docRef = db.collection("usuarios").doc(idUser);

    DocumentSnapshot docsnap = await docRef.get();

    if (docsnap.exists) {
      Navigator.of(context).popAndPushNamed("/Main");
    }
  }

  void acceptPressed(
      String nombre, String apellidos, BuildContext context) async {
    Usuarios usuario = Usuarios(
      nombre: nombre,
    );

    await db
        .collection("usuarios")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set(usuario.toFirestore())
        .onError((e, _) => print("Error writing document: $e"));

    Navigator.of(context).popAndPushNamed("/Home");
  }

  @override
  Widget build(BuildContext context) {
    IPExamen iNombre = IPExamen(
      textoGuia: "Introducir nombre",
      titulo: "NOMBRE",
    );
    IPExamen iApellidos = IPExamen(
      textoGuia: "Introducir apellidos",
      titulo: "APELLIDOS",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("ON BOARDING EXAMEN"),
        //esta barra de código es para quitar el icono de la flecha arriba a la izquierda de mi aplicacion
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            iNombre,
            iApellidos,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    acceptPressed(
                        iNombre.getText(), iApellidos.getText(), context);
                    print("NOMBRE " +
                        iNombre.getText() +
                        " " +
                        "APELLIDOS " +
                        iApellidos.getText());
                  },
                  child: Text("CONFIRMAR"),
                ),
              ],
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
