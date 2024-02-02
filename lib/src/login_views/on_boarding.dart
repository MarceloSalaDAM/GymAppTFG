import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../custom/input_text_2.dart';
import '../custom/picker_button.dart';
import '../firebase_objects/usuarios_firebase.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OnBoardingViewState();
  }
}

class _OnBoardingViewState extends State<OnBoardingView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String selectedEdad = '16';
  String selectedEstatura = '100';
  String selectedGenero = 'Hombre';
  String selectedPeso = '40';
  String? _imagePath;
  late IPApp iNombre = IPApp(textoGuia: "Introducir nombre", titulo: "NOMBRE");

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

  Future<void> _cargarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var file = File(pickedFile.path);

      // Obtén el UID del usuario actual
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Concatena el UID del usuario con el nombre del archivo
      String filename = 'profile_image_$userId.jpg';

      // Obtén la referencia al almacenamiento de Firebase
      Reference ref =
          FirebaseStorage.instance.ref().child("profileImages/$filename");
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        String imageUrl = await ref.getDownloadURL();
        setState(() {
          _imagePath = imageUrl;
        });
      });
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
      imageUrl: _imagePath,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("DATOS"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: const Color(0XFF0f7991),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: InkWell(
                      onTap: () {
                        _cargarFoto();
                      },
                      child: _imagePath != null
                          ? ClipOval(
                              child: Image.network(
                                _imagePath!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.add_a_photo,
                              size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: iNombre,
                  ),  const Divider(height: 10),
                  PickerButton<String>(
                    titulo: 'GENERO',
                    opciones: const ['Hombre', 'Mujer', 'Otro'],
                    valorSeleccionado: selectedGenero,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedGenero = newValue;
                        });
                      }
                    },
                  ),
                  const Divider(height: 10),
                  PickerButton<String>(
                    titulo: 'EDAD',
                    opciones:
                        List.generate(55, (index) => (16 + index).toString()),
                    valorSeleccionado: selectedEdad,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedEdad = newValue;
                        });
                      }
                    },
                  ),
                  const Divider(height: 10),
                  PickerButton<String>(
                    titulo: 'ESTATURA (cm)',
                    opciones:
                        List.generate(221, (index) => (100 + index).toString()),
                    valorSeleccionado: selectedEstatura,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedEstatura = newValue;
                        });
                      }
                    },
                  ),
                  const Divider(height: 10),
                  PickerButton<String>(
                    titulo: 'PESO (kg)',
                    opciones:
                        List.generate(160, (index) => (40 + index).toString()),
                    valorSeleccionado: selectedPeso,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedPeso = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          acceptPressed(
                            iNombre.myController.text,
                            // Usar el controlador de iNombre
                            selectedEdad,
                            selectedGenero,
                            selectedEstatura,
                            selectedPeso,
                            context,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFF0f7991),
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
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
