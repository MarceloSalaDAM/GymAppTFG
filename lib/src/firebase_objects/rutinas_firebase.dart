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

  Future<Rutina> obtenerRutinaActual() async {
    try {
      String? idUser = FirebaseAuth.instance.currentUser?.uid;

      // Obtén la referencia al documento de la rutina actual del usuario
      DocumentSnapshot rutinaSnapshot = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(idUser)
          .collection("rutinas")
          .doc(id) // Puedes ajustar esto según tu estructura de datos
          .get();

      // Verifica si el documento existe
      if (rutinaSnapshot.exists) {
        // Crea una instancia de la clase Rutina a partir de los datos obtenidos
        Rutina rutina = Rutina.fromFirestore(rutinaSnapshot);
        return rutina;
      } else {
        // Si el documento no existe, puedes manejarlo según tus necesidades
        throw Exception("La rutina no existe para el usuario actual");
      }
    } catch (e) {
      print("Error al obtener la rutina: $e");
      throw e; // Puedes manejar el error según tus necesidades
    }
  }
}
