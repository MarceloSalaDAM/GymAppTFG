import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../custom/picker_button.dart';

class ProfileView extends StatefulWidget {
  ProfileView({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController();
    // Carga los datos del usuario desde Firebase y configura los valores iniciales en los widgets.
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

        // Obtener la URL de la imagen desde Firestore
        String? imageUrl = userData['imageURL'];

        // Asignar la URL de la imagen a _imagePath para cargarla
        _imagePath = imageUrl;
      });
    }
  }

  Future<void> _cargarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
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

      // Actualiza los datos en Firebase utilizando el método `update`.
      await docRef.update({
        'nombre': nombre,
        'edad': edad,
        'genero': genero,
        'estatura': estatura,
        'peso': peso,
        'imageURL': _imagePath,
      });

      // Si también deseas actualizar la imagen, puedes hacerlo de manera similar.
      // Asegúrate de que `_imagePath` contenga la URL de la nueva imagen.

      if (_imagePath != null) {
        await docRef.update({
          'imageURL': _imagePath,
        });
      }

      // Notifica al usuario que la actualización se realizó con éxito.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos actualizados con éxito.'),
        ),
      );
    } catch (error) {
      // Maneja los errores si la actualización falla.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los datos: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (nombreController.text.isEmpty && _imagePath == null) {
      // Muestra una pantalla de carga mientras se obtienen los datos
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 90.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: InkWell(
                    onTap: () {
                      _cargarFoto();
                    },
                    child: _imagePath != null
                        ? ClipOval(
                      child: Image.file(File(_imagePath!)),
                    )
                        : Icon(Icons.add_a_photo,
                        size: 40, color: Colors.white),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: 'NOMBRE',
                    ),
                  ),
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      height: 25,
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
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Icon(Icons.save_alt),
                        ),
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
        ),
        backgroundColor: Colors.white,
      );
    }
  }
}
