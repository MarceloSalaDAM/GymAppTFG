import 'package:flutter/material.dart';
import '../firebase_objects/rutinas_firebase.dart';

class DetallesRutinaView extends StatelessWidget {
  final Rutina rutina;

  const DetallesRutinaView({required this.rutina});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Rutina'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID: ${rutina.id}'),
            Text('Nombre: ${rutina.nombreRutina}'),
            Text('Descripción: ${rutina.descripcionRutina}'),
            _buildDiasList(rutina.dias),
          ],
        ),
      ),
    );
  }

  Widget _buildDiasList(Map<String, dynamic> dias) {
    List<Widget> tiles = [];

    dias.forEach((nombreDia, infoDia) {
      List<Widget> ejerciciosTiles = [];

      if (infoDia['ejercicios'] != null) {
        for (var ejercicio in infoDia['ejercicios']) {
          ejerciciosTiles.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${ejercicio['nombre']}'),
                Text('Repeticiones: ${ejercicio['repeticiones']}'),
                Text('Series: ${ejercicio['series']}'),
                // Agrega más detalles según sea necesario
              ],
            ),
          );
        }
      }

      tiles.add(
        ExpansionTile(
          title: Text(nombreDia),
          children: ejerciciosTiles,
        ),
      );
    });

    return Container(
      color: Colors.red,
      child: Column(
        children: tiles,
      ),
    );
  }
}
