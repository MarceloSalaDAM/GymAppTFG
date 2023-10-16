import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom/input_text_2.dart';
import '../custom/picker_button.dart';
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
  String selectedEdad = '16'; // Valor seleccionado inicial para edad
  String selectedEstatura = '100'; // Valor seleccionado inicial para estatura
  String selectedGenero = 'Hombre'; // Valor seleccionado inicial para género
  String selectedPeso = '40'; // Valor seleccionado inicial para peso

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
      edad: edad,
      genero: genero,
      estatura: estatura,
      peso: peso,
    );

    await db
        .collection("usuarios")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set(usuario.toFirestore())
        .onError((e, _) => print("Error writing document: $e"));

    Navigator.of(context).popAndPushNamed("/Main");
  }

  @override
  Widget build(BuildContext context) {
    IPApp iNombre = IPApp(
      textoGuia: "Introducir nombre",
      titulo: "NOMBRE",
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("ONBOARDING"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(),
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              margin: EdgeInsets.fromLTRB(20, 100, 20, 0),
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 80.0,
                    height: 80.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        // Lógica al hacer clic en el botón flotante
                      },
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.add_a_photo),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: iNombre,
                  ),
                  PickerButton<String>(
                    titulo: 'GENERO',
                    opciones: ['Hombre', 'Mujer', 'Otro'],
                    valorSeleccionado: selectedGenero,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedGenero = newValue;
                        });
                      }
                    },
                  ),
                  PickerButton<String>(
                    titulo: 'EDAD',
                    opciones: List.generate(55, (index) => (16 + index).toString()),
                    valorSeleccionado: selectedEdad,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedEdad = newValue;
                        });
                      }
                    },
                  ),
                  PickerButton<String>(
                    titulo: 'ESTATURA (cm)',
                    opciones: List.generate(221, (index) => (100 + index ).toString()),
                    valorSeleccionado: selectedEstatura,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedEstatura = newValue;
                        });
                      }
                    },
                  ),
                  PickerButton<String>(
                    titulo: 'PESO (kg)',
                    opciones: List.generate(160, (index) => (40 + index).toString()),
                    valorSeleccionado: selectedPeso,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedPeso = newValue;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
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
                            child: Text("REGISTRO"),
                          ),
                        ),
                        onPressed: () {
                          acceptPressed(
                            iNombre.getText(),
                            selectedEdad,
                            selectedGenero,
                            selectedEstatura,
                            selectedPeso,
                            context,
                          );
                          print("NOMBRE " +
                              iNombre.getText() +
                              " " +
                              "EDAD " +
                              selectedEdad +
                              " " +
                              "GENERO " +
                              selectedGenero +
                              " " +
                              "ESTATURA " +
                              selectedEstatura +
                              " " +
                              "PESO " +
                              selectedPeso);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
