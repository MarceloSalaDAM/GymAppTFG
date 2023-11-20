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
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
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
    // No se permite cambiar la foto en este modo de solo lectura
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
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
                    child: Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: _imagePath != null
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
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildDataRow('NOMBRE', nombreController.text),
                    const SizedBox(height: 20),
                    _buildDataRow('GENERO', selectedGenero),
                    const SizedBox(height: 20),
                    // Utiliza el valor obtenido de Firebase
                    _buildDataRow('EDAD', selectedEdad),
                    const SizedBox(height: 20),
                    // Utiliza el valor obtenido de Firebase
                    _buildDataRow('ESTATURA (cm)', selectedEstatura),
                    const SizedBox(height: 20),
                    // Utiliza el valor obtenido de Firebase
                    _buildDataRow('PESO (kg)', selectedPeso),
                    // Utiliza el valor obtenido de Firebase
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      child: Icon(Icons.edit),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileView(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      );
    }
  }
}
