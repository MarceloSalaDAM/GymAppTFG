import 'package:flutter/material.dart';
import '../firebase_objects/rutinas_firebase.dart';

class DetallesRutinaView extends StatelessWidget {
  final Rutina rutina;

  const DetallesRutinaView({required this.rutina});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${rutina.nombreRutina}'),
      ),
      body: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.all(25.0),
        child: ListView(
          children: [
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
        ejerciciosTiles.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ejercicios',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        );

        for (var ejercicio in infoDia['ejercicios']) {
          ejerciciosTiles.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ${ejercicio['nombre']}'),
                Text('\t\t\tPeso: ${ejercicio['peso']} kg'),
                Text('\t\t\tRepeticiones: ${ejercicio['repeticiones']}'),
                Text('\t\t\tSeries: ${ejercicio['series']}'),
                // Agrega más detalles según sea necesario
              ],
            ),
          );
        }
      }


      tiles.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombreDia,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            SizedBox(height: 8.0),
            ...ejerciciosTiles,
            Divider(), // Un divisor opcional entre los días
          ],
        ),
      );
    });

    return Column(
      children: tiles,
    );
  }
}