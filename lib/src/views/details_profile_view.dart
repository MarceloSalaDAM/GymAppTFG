import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gym_app_tfg/src/views/profile_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../custom/picker_button.dart';

class DetailsProfileView extends StatefulWidget {
  const DetailsProfileView({Key? key}) : super(key: key);

  @override
  _DetailsProfileViewState createState() => _DetailsProfileViewState();
}

class _DetailsProfileViewState extends State<DetailsProfileView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String selectedEdad = '16';
  String selectedEstatura = '100';
  String selectedGenero = 'Hombre';
  String selectedPeso = '40';
  String? _imagePath;
  late TextEditingController nombreController;
  bool isLoading = true;
  bool _isEditing = false;
  bool _isImageLoading = false;

  late String _initialNombre;
  late String _initialEdad;
  late String _initialGenero;
  late String _initialEstatura;
  late String _initialPeso;

  @override
  void initState() {
    super.initState();
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
        isLoading = false;

        _initialNombre = nombreController.text;
        _initialEdad = selectedEdad;
        _initialGenero = selectedGenero;
        _initialEstatura = selectedEstatura;
        _initialPeso = selectedPeso;
      });
    }
  }

  void _revertChanges() {
    loadUserData();
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _cargarFoto() async {
    setState(() {
      _isImageLoading = true;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var file = File(pickedFile.path);
      String filename = 'profile_image.jpg';
      Reference ref =
          FirebaseStorage.instance.ref().child("profileImages/$filename");
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        String imageUrl = await ref.getDownloadURL();
        setState(() {
          _imagePath = imageUrl;
          _isImageLoading = false;
        });
      });
    } else {
      setState(() {
        _isImageLoading = false;
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

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNonEditableField(String label, String value) {
    return _buildDataRow(label, value);
  }

  Widget _buildEditableField(String label, List<String> options,
      String selectedValue, void Function(String?)? onChanged) {
    return PickerButton<String>(
      titulo: label,
      opciones: options,
      valorSeleccionado: selectedValue,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isEditing
          ? TextFormField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
              ),
            )
          : _buildDataRow(label, value),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón adicional solo si _isEditing es true
          if (_isEditing)
            MaterialButton(
              height: 25,
              color: Colors.red,
              // Puedes ajustar el color según tus necesidades
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
              ),
              padding: const EdgeInsets.all(8.0),
              textColor: Colors.white,
              splashColor: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(0),
                child: Icon(
                  Icons.cancel, // Reemplaza con el icono que desees
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text("¿Estás seguro que quieres salir?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancelar"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Cierra el cuadro de diálogo
                          },
                        ),
                        TextButton(
                          child: const Text("Aceptar"),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Cierra el cuadro de diálogo
                            _revertChanges();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          // Spacer para agregar espacio entre los dos botones
          const Spacer(),
          // Botón existente
          MaterialButton(
            height: 25,
            color: const Color(0xFF0C7075),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
            padding: const EdgeInsets.all(8.0),
            textColor: Colors.white,
            splashColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Icon(
                _isEditing ? Icons.save_alt : Icons.edit,
              ),
            ),
            onPressed: () {
              if (_isEditing) {
                acceptPressed(
                  nombreController.text,
                  selectedEdad,
                  selectedGenero,
                  selectedEstatura,
                  selectedPeso,
                );
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.blue,
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                  top: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                width: 140.0,
                height: 140.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: InkWell(
                    onTap: _isEditing ? _cargarFoto : null,
                    child: Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: _isImageLoading
                            ? const CircularProgressIndicator()
                            : _imagePath != null
                                ? Image.network(
                                    _imagePath!,
                                    fit: BoxFit.cover,
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
                  _buildTextField('NOMBRE', nombreController.text, _isEditing),
                  const SizedBox(height: 20),
                  _isEditing
                      ? _buildEditableField(
                          'GENERO', ['Hombre', 'Mujer', 'Otro'], selectedGenero,
                          (newValue) {
                          setState(() {
                            selectedGenero = newValue!;
                          });
                        })
                      : _buildNonEditableField('GENERO', selectedGenero),
                  const SizedBox(height: 20),
                  _isEditing
                      ? _buildEditableField(
                          'EDAD',
                          List.generate(55, (index) => (16 + index).toString()),
                          selectedEdad, (newValue) {
                          setState(() {
                            selectedEdad = newValue!;
                          });
                        })
                      : _buildNonEditableField('EDAD', selectedEdad),
                  const SizedBox(height: 5),
                  _isEditing
                      ? _buildEditableField(
                          'ESTATURA (cm)',
                          List.generate(
                              221, (index) => (100 + index).toString()),
                          selectedEstatura, (newValue) {
                          setState(() {
                            selectedEstatura = newValue!;
                          });
                        })
                      : _buildNonEditableField(
                          'ESTATURA (cm)', selectedEstatura),
                  const SizedBox(height: 5),
                  _isEditing
                      ? _buildEditableField(
                          'PESO (kg)',
                          List.generate(
                              160, (index) => (40 + index).toString()),
                          selectedPeso, (newValue) {
                          setState(() {
                            selectedPeso = newValue!;
                          });
                        })
                      : _buildNonEditableField('PESO (kg)', selectedPeso),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
