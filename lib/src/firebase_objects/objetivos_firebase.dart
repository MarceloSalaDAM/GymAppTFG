import 'package:cloud_firestore/cloud_firestore.dart';

class Objetivos {
  final String titulo;
  final String? descripcion;
  final String? beneficios;
  final String? imagen;

  Objetivos({
    this.titulo = " ",
    this.descripcion = " ",
    this.beneficios = " ",
    this.imagen = " ",
  });

  factory Objetivos.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Objetivos(
      titulo: data?['titulo'],
      descripcion: data?['descripcion'],
      beneficios: data?['beneficios'],
      imagen: data?['imagen'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (titulo != null) "titulo": titulo,
      if (descripcion != null) "descripcion": descripcion,
      if (beneficios != null) "beneficios": beneficios,
      if (imagen != null) "imagen": imagen,
    };
  }

  static Future<List<Objetivos>> getEjerciciosFromFirebase() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('objetivos').get();

    return querySnapshot.docs.map((doc) {
      return Objetivos.fromFirestore(doc, null);
    }).toList();
  }
}
