import 'package:flutter/material.dart';
import '../firebase_objects/ejercicios_firebase.dart';

// Clase para personalizar las tarjetas
class CustomCard extends StatelessWidget {
  final Ejercicios ejercicio;

  CustomCard({required this.ejercicio});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide()
        ),
        color: Colors.grey,
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${ejercicio.nombre ?? 'Nombre no disponible'}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (ejercicio.imagen != null)
                FutureBuilder(
                  future: precacheImage(
                    NetworkImage(ejercicio.imagen!),
                    context,
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Image.network(ejercicio.imagen!);
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              Text(
                'Descripción: ${ejercicio.descripcion ?? 'Descripción no disponible'}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Comentarios: ${ejercicio.comentarios ?? 'Comentarios no disponibles'}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Grupo: ${ejercicio.grupo ?? 'Grupo no disponible'}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Tipo: ${ejercicio.tipo ?? 'Tipo no disponible'}',
                style: TextStyle(fontSize: 16),
              ),
              if (ejercicio.musculos != null && ejercicio.musculos!.isNotEmpty)
                Text(
                  'Músculos: ${ejercicio.musculos!.join(", ")}',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
