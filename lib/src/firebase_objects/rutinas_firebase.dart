import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Rutina {
  final String? id;
  final String? nombreRutina;
  final String? descripcionRutina;
  final String? grupo;
  final Map<String, dynamic> dias;

  Rutina({
    required this.id,
     this.nombreRutina,
     this.descripcionRutina,
     this.grupo,
    required this.dias,
  });

  factory Rutina.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    return Rutina(
      id: snapshot.id,
      // Obtén el ID de Firestore
      nombreRutina: data['nombre'] ?? '',
      descripcionRutina: data['descripcion'] ?? '',
      grupo: data['grupo'] ?? '',
      dias: data['dias'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "nombre": nombreRutina,
      "descripcion": descripcionRutina,
      "grupo": grupo,
      "dias": dias,
    };
  }

  // Método para eliminar la rutina de Firestore
  Future<void> deleteFromFirestore() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    try {
      // Asegúrate de que id no sea null
      if (id != null) {
        // Suponiendo que el documento de usuario está en la colección "usuarios"
        // y tiene una subcolección "rutinas"
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(
                idUser) // Ajusta esto según la estructura real de tu base de datos
            .collection("rutinas")
            .doc(id)
            .delete();
        print("DATOS-------->> " + id! + "   " + idUser!);
      } else {
        print("ID de la rutina es null. No se puede eliminar.");
      }
    } catch (e) {
      print("Error al eliminar la rutina: $e");
      throw e; // Puedes manejar el error según tus necesidades
    }
  }
}
