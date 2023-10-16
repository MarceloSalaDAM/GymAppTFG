import 'package:cloud_firestore/cloud_firestore.dart';

class Usuarios {
  /* Declaracion de los atributos de la clase Usuarios,
 para la conexion con el Firebase*/
  final String? nombre;
  final String? edad;
  final String? estatura;
  final String? imageUrl;
  final String? peso;
  final String? genero;

  Usuarios({
    this.nombre = " ",
    this.edad = " ",
    this.estatura = " ",
    this.imageUrl = " ",
    this.peso = " ",
    this.genero = " ",
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
        imageUrl: data?['fotoPerfil'],
        peso: data?['peso'],
        genero: data?['genero']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (nombre != null) "nombre": nombre,
      if (edad != null) "edad": edad,
      if (estatura != null) "estatura": estatura,
      if (peso != null) "peso": peso,
      if (genero != null) "genero": genero,
      if (imageUrl != null) "fotoPerfil": imageUrl,
    };
  }
}
