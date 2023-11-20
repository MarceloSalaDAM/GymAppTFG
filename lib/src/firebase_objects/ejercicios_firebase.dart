import 'package:cloud_firestore/cloud_firestore.dart';

class Ejercicios {
  final String? nombre;
  final String? descripcion;
  final String? grupo;
  final String? imagen;
  final String? comentarios;
  final List<String>? musculos;

  Ejercicios({
    this.nombre = " ",
    this.descripcion = " ",
    this.grupo = " ",
    this.imagen = " ",
    this.comentarios = " ",
    required this.musculos,
  });

  factory Ejercicios.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Ejercicios(
      nombre: data?['nombre'],
      descripcion: data?['descripcion'],
      grupo: data?['grupo'],
      imagen: data?['imagen'],
      comentarios: data?['comentarios'],
      musculos: List<String>.from(data?['musculos'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (descripcion != null) "descripcion": descripcion,
      if (grupo != null) "grupo": grupo,
      if (imagen != null) "imagen": imagen,
      if (comentarios != null) "comentarios": comentarios,
      if (musculos != null) "musculos": musculos,
    };
  }

  static Future<List<Ejercicios>> getEjerciciosFromFirebase() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('ejercicios').get();

    return querySnapshot.docs.map((doc) {
      return Ejercicios.fromFirestore(doc, null);
    }).toList();
  }
}
