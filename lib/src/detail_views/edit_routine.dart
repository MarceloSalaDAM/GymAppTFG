import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditarEjerciciosView extends StatefulWidget {
  final List<dynamic> ejercicios;

  const EditarEjerciciosView({required this.ejercicios});

  @override
  _EditarEjerciciosViewState createState() => _EditarEjerciciosViewState();
}

class _EditarEjerciciosViewState extends State<EditarEjerciciosView> {
  TextEditingController _seriesController = TextEditingController();
  TextEditingController _repeticionesController = TextEditingController();
  TextEditingController _pesoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Ejercicios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.ejercicios.length,
          itemBuilder: (context, index) {
            final ejercicio = widget.ejercicios[index] as Map<String, dynamic>;
            return _buildEjercicioCard(ejercicio);
          },
        ),
      ),
    );
  }

  Widget _buildEjercicioCard(Map<String, dynamic> ejercicio) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ejercicio['nombre']}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Series: ${ejercicio['series']}'),
            Text('Repeticiones: ${ejercicio['repeticiones']}'),
            Text('Peso: ${ejercicio['peso']} kg'),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nuevas series',
              ),
              controller: _seriesController,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nuevas repeticiones',
              ),
              controller: _repeticionesController,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nuevo peso en kg',
              ),
              controller: _pesoController,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (ejercicio['rutinaId'] != null &&
                    ejercicio['dia'] != null &&
                    ejercicio['ejercicioId'] != null) {
                  actualizarEjercicioEnFirebase(
                    {
                      'nombre': ejercicio['nombre'],
                      'peso': _pesoController.text,
                      'repeticiones': _repeticionesController.text,
                      'series': _seriesController.text,
                    },
                  );
                } else {
                  print('Alguno de los valores clave es nulo.');
                }
              },
              child: Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void actualizarEjercicioEnFirebase(
    Map<String, dynamic> ejercicio,
  ) async {
    try {
      // Verificar que los valores clave necesarios no sean nulos
      if (ejercicio['rutinaId'] != null &&
          ejercicio['dia'] != null &&
          ejercicio['ejercicioId'] != null) {
        // Obtener el ID del usuario actual
        String userId = FirebaseAuth.instance.currentUser!.uid;

        // Crear una referencia al documento de la rutina en Firestore
        DocumentReference rutinaRef = FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .collection('rutinas')
            .doc(ejercicio['rutinaId']);

        // Actualizar los valores del ejercicio en el día específico
        await rutinaRef.update({
          'dias.${ejercicio['dia']}.ejercicios.${ejercicio['ejercicioId']}': {
            'peso': _pesoController.text, // Nuevo peso
            'repeticiones': _repeticionesController.text, // Nuevas repeticiones
            'series': _seriesController.text, // Nuevas series
          },
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ejercicio actualizado con éxito'),
          ),
        );
      } else {
        print('Alguno de los valores clave es nulo.');
      }
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante el proceso
      print('Error al actualizar el ejercicio en Firebase: $e');

      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el ejercicio'),
        ),
      );
    }
  }
}
