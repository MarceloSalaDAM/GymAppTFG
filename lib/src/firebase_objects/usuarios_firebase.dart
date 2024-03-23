import 'package:cloud_firestore/cloud_firestore.dart';

class Usuarios {
  final String? nombre;
  final String? edad;
  final String? estatura;
  final String? imageUrl;
  final String? peso;
  final String? genero;
  final Timestamp? ultimaMod; // Nuevo campo para almacenar la fecha y hora de la última modificación

  Usuarios({
    this.nombre = " ",
    this.edad = " ",
    this.estatura = " ",
    this.imageUrl = " ",
    this.peso = " ",
    this.genero = " ",
    this.ultimaMod, // Agregamos el nuevo campo aquí
  });

  factory Usuarios.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Usuarios(
      nombre: data?['nombre'],
      edad: data?['edad'],
      estatura: data?['estatura'],
      imageUrl: data?['imageURL'],
      peso: data?['peso'],
      genero: data?['genero'],
      ultimaMod: data?['ultimaMod'], // Actualizamos la asignación con el nuevo campo
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (edad != null) "edad": edad,
      if (estatura != null) "estatura": estatura,
      if (peso != null) "peso": peso,
      if (genero != null) "genero": genero,
      if (imageUrl != null) "imageURL": imageUrl,
      'ultimaMod': Timestamp.now(), // Almacenamos la fecha y hora actual al actualizar
    };
  }
}
