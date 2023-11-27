import 'package:flutter/material.dart';
import '../firebase_objects/ejercicios_firebase.dart';

class ExerciseListScreen extends StatelessWidget {
  final List<Ejercicios> ejercicios;

  const ExerciseListScreen({Key? key, required this.ejercicios})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Ejercicios'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ejercicios.length,
              itemBuilder: (BuildContext context, int index) {
                final ejercicio = ejercicios[index];
                return Card(
                  child: ListTile(
                    title: Text(ejercicio.nombre ?? 'Nombre no disponible'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ejercicio.imagen != null)
                          Image.network(ejercicio.imagen!),
                        Text(
                            '***Descripción: ${ejercicio.descripcion ?? 'Descripción no disponible'}'),
                        Text(
                            '***Comentarios: ${ejercicio.comentarios ?? 'Comentarios no disponibles'}'),
                        Text('***Grupo: ${ejercicio.grupo ?? 'Grupo no disponible'}'),
                        Text('***Tipo: ${ejercicio.tipo ?? 'Tipo no disponible'}'),
                        if (ejercicio.musculos != null &&
                            ejercicio.musculos!.isNotEmpty)
                          Text('***Músculos: ${ejercicio.musculos!.join(", ")}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
