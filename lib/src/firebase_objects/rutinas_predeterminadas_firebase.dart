import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../detail_views/main_view.dart';

class RutinaPredeterminada {
  final String? idPred;
  final String? nombreRutinaPred;
  final String? descripcionRutinaPred;
  final String? grupoPred;
  final String? nivelPred;
  final Map<String, dynamic> diasPred;

  RutinaPredeterminada({
    required this.idPred,
    this.nombreRutinaPred,
    this.descripcionRutinaPred,
    this.grupoPred,
    this.nivelPred,
    required this.diasPred,
  });

  factory RutinaPredeterminada.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    return RutinaPredeterminada(
      idPred: snapshot.id,
      // Obtén el ID de Firestore
      nombreRutinaPred: data['nombre'] ?? '',
      descripcionRutinaPred: data['descripcion'] ?? '',
      grupoPred: data['grupo'] ?? '',
      nivelPred: data['nivel'] ?? '',
      diasPred: data['dias'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "nombre": nombreRutinaPred,
      "descripcion": descripcionRutinaPred,
      "grupo": grupoPred,
      "nivel": nivelPred,
      "dias": diasPred,
    };
  }

  Future<void> saveToProfile(BuildContext context) async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;

    try {
      if (idPred != null) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(idUser)
            .collection("rutinas")
            .doc(idPred)
            .get();

        // Verificar si la rutina ya está en el perfil
        if (documentSnapshot.exists) {
          // Mostrar Snackbar indicando que la rutina ya está añadida
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('YA TIENES LA RUTINA'),
              duration: Duration(milliseconds: 2000),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // La rutina no está en el perfil, añádela
          await FirebaseFirestore.instance
              .collection("usuarios")
              .doc(idUser)
              .collection("rutinas")
              .doc(idPred)
              .set(toFirestore());

          // Mostrar Snackbar indicando que la rutina se añadió correctamente
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('RUTINA GUARDADA'),
              duration: Duration(milliseconds: 2000),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainViewApp(),
            ),
            (route) => false,
          );

          print("Rutina guardada correctamente: $idPred");
        }
      } else {
        print("ID de la rutina es null. No se puede guardar.");
      }
    } catch (e) {
      print("Error al guardar la rutina: $e");
      throw e;
    }
  }

/*
  // Método para eliminar la rutina de Firestore
  Future<void> removeFromProfile() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    try {
      // Asegúrate de que id no sea null
      if (idPred != null) {
        // Suponiendo que el documento de usuario está en la colección "usuarios"
        // y tiene una subcolección "rutinas"
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(
            idUser) // Ajusta esto según la estructura real de tu base de datos
            .collection("rutinas")
            .doc(idPred)
            .delete();
        print("Rutina eliminada correctamente: $idPred");
      } else {
        print("ID de la rutina es null. No se puede eliminar.");
      }
    } catch (e) {
      print("Error al eliminar la rutina: $e");
      throw e; // Puedes manejar el error según tus necesidades
    }
  }*/
}
