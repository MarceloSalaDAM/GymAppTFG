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
              builder: (context) => const MainViewApp(),
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
      rethrow;
    }
  }

  /*Future<void> saveToGlobalCollection(BuildContext context) async {
    try {
      // Generar un nuevo ID para la rutina
      String newId = FirebaseFirestore.instance
          .collection("rutinas_predeterminadas")
          .doc()
          .id;

      if (newId.isNotEmpty) {
        // Añadir la rutina a la colección global con el nuevo ID
        await FirebaseFirestore.instance
            .collection("rutinas_predeterminadas")
            .doc(newId)
            .set(toFirestore());

        print("Rutina guardada en la colección global: $newId");
      } else {
        print("No se pudo generar un nuevo ID para la rutina.");
      }
    } catch (e) {
      print("Error al guardar la rutina en la colección global: $e");
      throw e;
    }
  }*/

}
