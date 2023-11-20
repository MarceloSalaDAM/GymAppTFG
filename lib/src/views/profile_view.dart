import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../custom/picker_button.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String selectedEdad = '16';
  String selectedEstatura = '100';
  String selectedGenero = 'Hombre';
  String selectedPeso = '40';
  String? _imagePath;
  late TextEditingController nombreController;
  late bool isLoading; // Nuevo: bandera de carga

  @override
  void initState() {
    super.initState();
    isLoading = true; // Establecer isLoading a true al inicio
    nombreController = TextEditingController();
    loadUserData();
  }

  Future<void> loadUserData() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    final docRef = db.collection("usuarios").doc(idUser);

    DocumentSnapshot docsnap = await docRef.get();

    if (docsnap.exists) {
      Map<String, dynamic> userData = docsnap.data() as Map<String, dynamic>;
      setState(() {
        nombreController.text = userData['nombre'];
        selectedEdad = userData['edad'];
        selectedGenero = userData['genero'];
        selectedEstatura = userData['estatura'];
        selectedPeso = userData['peso'];
        _imagePath = userData['imageURL'];
        isLoading =
            false; // Cambiar isLoading a false después de cargar los datos
      });
    }
  }

  Future<void> _cargarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var file = File(pickedFile.path);
      String filename =
          FirebaseAuth.instance.currentUser!.uid + "_profile_image.jpg";
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

  void acceptPressed(
    String nombre,
    String edad,
    String genero,
    String estatura,
    String peso,
  ) async {
    try {
      String? idUser = FirebaseAuth.instance.currentUser?.uid;
      final docRef = db.collection("usuarios").doc(idUser);

      await docRef.update({
        'nombre': nombre,
        'edad': edad,
        'genero': genero,
        'estatura': estatura,
        'peso': peso,
        'imageURL': _imagePath,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados con éxito.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los datos: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Muestra una pantalla de carga mientras se obtienen los datos
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  border:
                      Border(bottom: BorderSide(color: Colors.black, width: 2), top: BorderSide(color: Colors.black, width: 2) ),
                ),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                  width: 120.0,
                  height: 120.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: _cargarFoto,
                      child: Container(
                        width: 120.0,
                        height: 120.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: _imagePath != null
                              ? Image.network(
                                  _imagePath!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    }
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'NOMBRE',
                        ),
                      ),
                    ),
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
                    PickerButton<String>(
                      titulo: 'ESTATURA (cm)',
                      opciones: List.generate(
                          221, (index) => (100 + index).toString()),
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
                      opciones: List.generate(
                          160, (index) => (40 + index).toString()),
                      valorSeleccionado: selectedPeso,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedPeso = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                          height: 25,
                          color: Color(0xFF0C7075),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.white,
                          splashColor: Colors.white,
                          child: const Padding(
                            padding: EdgeInsets.all(0),
                            child: Icon(Icons.save_alt),
                          ),
                          onPressed: () {
                            acceptPressed(
                              nombreController.text,
                              selectedEdad,
                              selectedGenero,
                              selectedEstatura,
                              selectedPeso,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      );
    }
  }
}

