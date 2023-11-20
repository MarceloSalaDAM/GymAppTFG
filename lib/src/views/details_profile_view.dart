import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        _imagePath = userData['imageURL'];
        isLoading = false;
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

            fontSize:25,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize:20,
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
                    _buildDataRow('GENERO', 'Hombre'), // Puedes cambiarlo según el valor almacenado
                    _buildDataRow('EDAD', '16'), // Puedes cambiarlo según el valor almacenado
                    _buildDataRow('ESTATURA (cm)', '100'), // Puedes cambiarlo según el valor almacenado
                    _buildDataRow('PESO (kg)', '40'), // Puedes cambiarlo según el valor almacenado
                    const SizedBox(height: 20),
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