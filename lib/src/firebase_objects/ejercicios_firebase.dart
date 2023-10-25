import 'package:cloud_firestore/cloud_firestore.dart';

class Ejercicios {
  final String? nombre;
  final String? descripcion;

  Ejercicios({
    this.nombre = " ",
    this.descripcion = " ",
  });

  factory Ejercicios.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Ejercicios(
      nombre: data?['nombre'],
      descripcion: data?['descripcion'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (descripcion != null) "descripcion": descripcion,
    };
  }
}
