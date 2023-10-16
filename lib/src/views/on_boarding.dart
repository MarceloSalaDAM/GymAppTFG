import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../custom/InputText.dart';
import '../firebase_objects/usuarios_firebase.dart';

class OnBoardingView extends StatefulWidget {
  OnBoardingView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OnBoardingViewState();
  }
}

class _OnBoardingViewState extends State<OnBoardingView> {
  var txt = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    checkExistingProfile();
  }

  void checkExistingProfile() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    final docRef = db.collection("usuarios").doc(idUser);

    DocumentSnapshot docsnap = await docRef.get();

    if (docsnap.exists) {
      Navigator.of(context).popAndPushNamed("/Main");
    }
  }

  void acceptPressed(String nombre, String edad, String genero, String estatura,
      String peso, BuildContext context) async {
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
    IPExamen iEdad = IPExamen(
      textoGuia: "Introducir edad",
      titulo: "EDAD",
    );
    IPExamen iGenero = IPExamen(
      textoGuia: "Introducir genero",
      titulo: "GENERO",
    );
    IPExamen iEstatura = IPExamen(
      textoGuia: "Introducir estatura(cm)",
      titulo: "ESTATURA",
    );
    IPExamen iPeso = IPExamen(
      textoGuia: "Introducir peso(kg)",
      titulo: "PESO",
    );

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 200), // Espacio para el botón flotante
                iNombre,
                iEdad,
                iGenero,
                iEstatura,
                iPeso,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        acceptPressed(
                            iNombre.getText(),
                            iEdad.getText(),
                            iGenero.getText(),
                            iEstatura.getText(),
                            iPeso.getText(),
                            context);
                        print("NOMBRE " +
                            iNombre.getText() +
                            " " +
                            "EDAD " +
                            iEdad.getText() +
                            " " +
                            "GENERO " +
                            iGenero.getText() +
                            " " +
                            "ESTATURA " +
                            iEstatura.getText() +
                            " " +
                            "PESO " +
                            iPeso.getText());
                      },
                      child: Text("CONFIRMAR"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
              top: 80, // Ajusta la posición vertical según sea necesario
              left: 0,
              right: 0,
              child: Container(

                width: 80.0, // Ancho deseado
                height: 80.0, // Alto deseado
                child: FloatingActionButton(
                  onPressed: () {
                    // Lógica al hacer clic en el botón flotante
                  },
                  backgroundColor: Colors.blue, // Cambiar el color a azul
                  child: Icon(Icons.add_a_photo),
                ),
              )),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
