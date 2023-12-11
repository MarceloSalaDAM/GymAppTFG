import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../firebase_objects/rutinas_firebase.dart';

class RutinasUsuarioView extends StatefulWidget {
  @override
  _RutinasUsuarioViewState createState() => _RutinasUsuarioViewState();
}

class _RutinasUsuarioViewState extends State<RutinasUsuarioView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Rutina> rutinas = [];

  @override
  void initState() {
    super.initState();
    // Cargar datos de usuario y rutinas asociadas
    loadUserData();
  }

  // Carga de datos de usuario y rutinas asociadas
  Future<void> loadUserData() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    final docRef = db.collection("usuarios").doc(idUser);

    DocumentSnapshot docsnap = await docRef.get();

    if (docsnap.exists) {
      // Cargar datos de usuario
      Map<String, dynamic> userData = docsnap.data() as Map<String, dynamic>;
      setState(() {
        // Aquí puedes manejar los datos del usuario si es necesario
      });

      // Obtener la subcolección de rutinas asociadas al usuario
      final rutinasRef = docRef.collection('rutinas');
      final rutinasSnap = await rutinasRef.get();

      setState(() {
        rutinas =
            rutinasSnap.docs.map((doc) => Rutina.fromFirestore(doc)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutinas del Usuario'),
      ),
      body: ListView.builder(
        itemCount: rutinas.length,
        itemBuilder: (context, index) {
          return _buildRutinaTile(rutinas[index]);
        },
      ),
    );
  }

  Widget _buildRutinaTile(Rutina rutina) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: ExpansionTile(
        title: Text(rutina.nombreRutina),
        children: [
          ListTile(
            title: Text('Descripción: ${rutina.descripcionRutina}'),
          ),
          _buildDiasList(rutina.dias),
        ],
      ),
    );
  }

  Widget _buildDiasList(Map<String, dynamic> dias) {
    List<Widget> tiles = [];
    dias.forEach((nombreDia, infoDia) {
      List<Widget> ejerciciosTiles = [];

      if (infoDia['ejercicios'] != null) {
        for (var ejercicio in infoDia['ejercicios']) {
          ejerciciosTiles.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${ejercicio['nombre']}'),
                Text('Repeticiones: ${ejercicio['repeticiones']}'),
                Text('Series: ${ejercicio['series']}'),
                // Agrega más detalles según sea necesario
              ],
            ),
          );
        }
      }

      tiles.add(ListTile(
        title: Text(nombreDia),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: ejerciciosTiles,
        ),
      ));
    });

    return Column(
      children: tiles,
    );
  }

}
