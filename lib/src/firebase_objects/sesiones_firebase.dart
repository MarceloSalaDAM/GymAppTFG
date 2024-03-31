import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sesion {
  final String? duracion;
  final DateTime? fecha;
  final String? dia;
  final String? grupo;

  Sesion(
    this.dia,
    this.grupo, {
    this.duracion,
    this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'duracion': duracion,
      'fecha': fecha,
      'dia': dia,
      'grupo': grupo,
    };
  }

  static Future<List<Sesion>> descargarSesionesUsuarioActual() async {
    try {
      // Obtener el usuario actualmente autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Obtener la colección "sesiones" del usuario actual
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .collection('sesiones')
                .get();

        // Convertir los documentos obtenidos en objetos Sesion
        List<Sesion> sesiones = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Sesion(
            data['dia'],
            data['grupo'],
            duracion: data['duracion'],
            fecha: (data['fecha'] as Timestamp).toDate(),
          );
        }).toList();

        return sesiones;
      } else {
        throw Exception("No se ha encontrado ningún usuario autenticado.");
      }
    } catch (error) {
      throw Exception("Error al descargar las sesiones: $error");
    }
  }
}
