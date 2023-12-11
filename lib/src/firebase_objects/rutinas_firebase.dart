import 'package:cloud_firestore/cloud_firestore.dart';

class Rutina {
  final String nombreRutina;
  final String descripcionRutina;
  final String? grupo;
  final Map<String, dynamic> dias;

  Rutina({
    required this.nombreRutina,
    required this.descripcionRutina,
    required this.grupo,
    required this.dias,
  });

  factory Rutina.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    return Rutina(
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
}
