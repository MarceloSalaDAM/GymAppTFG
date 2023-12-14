import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RutinaPredeterminada {
  final String? idPred;
  final String? nombreRutinaPred;
  final String? descripcionRutinaPred;
  final String? grupoPred;
  final Map<String, dynamic> diasPred;

  RutinaPredeterminada({
    required this.idPred,
    this.nombreRutinaPred,
    this.descripcionRutinaPred,
    this.grupoPred,
    required this.diasPred,
  });

  factory RutinaPredeterminada.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    return RutinaPredeterminada(
      idPred: snapshot.id,
      // Obtén el ID de Firestore
      nombreRutinaPred: data['nombreRutinaPred'] ?? '',
      descripcionRutinaPred: data['descripcionRutinaPred'] ?? '',
      grupoPred: data['grupoPred'] ?? '',
      diasPred: data['diasPred'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "nombreRutinaPred": nombreRutinaPred,
      "descripcionRutinaPred": descripcionRutinaPred,
      "grupoPred": grupoPred,
      "diasPred": diasPred,
    };
  }

  // Método para guardar la rutina en Firestore
  Future<void> saveToProfile() async {
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
            .set(toFirestore()); // Guarda los datos de la rutina
        print("Rutina guardada correctamente: $idPred");
      } else {
        print("ID de la rutina es null. No se puede guardar.");
      }
    } catch (e) {
      print("Error al guardar la rutina: $e");
      throw e; // Puedes manejar el error según tus necesidades
    }
  }

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
  }
}
