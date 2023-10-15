import 'package:cloud_firestore/cloud_firestore.dart';

class Usuarios {
  /* Declaracion de los atributos de la clase Usuarios,
  para la conexion con el Firebase*/
  final String? nombre;

  Usuarios({
    this.nombre = " ",
  });

  factory Usuarios.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Usuarios(nombre: data?['nombre']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
    };
  }
}
