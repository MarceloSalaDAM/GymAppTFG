import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../custom/input_text_2.dart';
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
  late List<String> weightOptions;
  String selectedWeight = '--Seleccionar--'; // Valor seleccionado inicial

  _OnBoardingViewState() {
    int minWeight = 40;
    int maxWeight = 140;
    weightOptions = List.generate(maxWeight - minWeight + 1, (index) {
      return (minWeight + index).toString() + ' kg';
    });
    weightOptions.insert(0, selectedWeight); // Inserta "--Seleccionar--" en la primera posición de la lista
  }

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
    IPApp iEdad = IPApp(
      textoGuia: "Introducir edad",
      titulo: "EDAD",
    );
    IPApp iGenero = IPApp(
      textoGuia: "Introducir genero",
      titulo: "GENERO",
    );
    IPApp iEstatura = IPApp(
      textoGuia: "Introducir estatura(cm)",
      titulo: "ESTATURA",
    );

    return Scaffold(
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
              margin: EdgeInsets.fromLTRB(20, 35, 20, 0),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: iEdad,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: iGenero,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: iEstatura,
                  ),
                  ListTile(
                    title: Text('Peso'),
                    trailing: DropdownButton<String>(
                      value: selectedWeight,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedWeight = newValue!;
                        });
                      },
                      items: weightOptions.map((String weight) {
                        return DropdownMenuItem<String>(
                          value: weight,
                          child: Text(weight),
                        );
                      }).toList(),
                    ),
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
                            iEdad.getText(),
                            iGenero.getText(),
                            iEstatura.getText(),
                            selectedWeight,
                            context,
                          );
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
                              selectedWeight);
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

