import 'package:cloud_firestore/cloud_firestore.dart';

class Rutina {
  final String? nombre;
  final String descripcion;
  final List<Map<String, dynamic>> dias;

  Rutina({
    required this.nombre,
    required this.descripcion,
    required this.dias,
  });

  factory Rutina.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    final List<Map<String, dynamic>> dias = List<Map<String, dynamic>>.from(
      data?['dias'] ?? [],
    );

    return Rutina(
      nombre: data?['nombre'] ?? '', // Use an empty string if nombre is null
      descripcion: data?['descripcion'] ?? '',
      dias: dias,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (descripcion != null) "descripcion": descripcion,
      "dias": dias,
    };
  }
}
