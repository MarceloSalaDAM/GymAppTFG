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
      color: Colors.blueGrey,
      shape: RoundedRectangleBorder(
        side: const BorderSide(),
      ),
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: ExpansionTile(
        title: Text(
          rutina.nombreRutina,
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        children: [
          ListTile(
            title: Text(
              'Descripción:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            subtitle: Text(
              '${rutina.descripcionRutina}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
          _buildDiasList(rutina.dias),
        ],
      ),
    );
  }

  Widget _buildDiasList(Map<String, dynamic> dias) {
    List<Widget> tiles = [];
    final eyeIcon = Icon(
        Icons.remove_red_eye); // Icono genérico para todas las ExpansionTile

    dias.forEach((nombreDia, infoDia) {
      List<Widget> ejerciciosTiles = [];

      /*if (infoDia['ejercicios'] != null) {
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
    }*/

      tiles.add(Container(
        margin: EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              child: Text(
                nombreDia,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            if (infoDia['grupo'] != null)
              Text(
                '${infoDia['grupo']}',
                style: TextStyle(fontWeight: FontWeight.w700,fontSize: 18),
              ),
            const SizedBox(height: 5),
            // Puedes agregar más detalles sobre el día aquí
            ...ejerciciosTiles,
          ],
        ),
      ));
    });

    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.all(Radius.circular(18.0)),
      ),
      child: Column(
        children: [
          ...tiles,
          IconButton(
            icon: eyeIcon,
            onPressed: () {
              // Lógica que se ejecutará al hacer clic en el botón de ojo
              // Puedes abrir un nuevo widget o realizar alguna otra acción
            },
          ),
        ],
      ),
    );
  }
}
