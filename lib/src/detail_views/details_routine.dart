import 'package:flutter/material.dart';
import '../firebase_objects/rutinas_firebase.dart';

class DetallesRutinaView extends StatelessWidget {
  final Rutina rutina;

  const DetallesRutinaView({required this.rutina});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        title: Text(
          '${rutina.nombreRutina}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        margin: EdgeInsets.all(25.0),
        child: Card(
          elevation: 4.0,
          child: ListView(
            padding: EdgeInsets.all(10.0),
            children: [
              _buildDiasList(rutina.dias),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiasList(Map<String, dynamic> dias) {
    List<Widget> tiles = [];

    final diasOrdenados = [
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO',
      'DOMINGO'
    ];

    diasOrdenados.forEach((nombreDia) {
      final diaEnMayusculas = nombreDia;

      if (dias.containsKey(diaEnMayusculas)) {
        List<Widget> ejerciciosTiles = [];

        if (dias[diaEnMayusculas]['ejercicios'] != null) {
          ejerciciosTiles.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ejercicios',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          );

          for (var ejercicio in dias[diaEnMayusculas]['ejercicios']) {
            ejerciciosTiles.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ${ejercicio['nombre']}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        '\t\t\tSeries: ',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                      Text(
                        '${ejercicio['series']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '\t\t\tRepeticiones: ',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                      Text(
                        '${ejercicio['repeticiones']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '\t\t\tPeso: ',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        '${ejercicio['peso']} kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
                diaEnMayusculas,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 27.0,
                ),
              ),
              const SizedBox(height: 8.0),
              const Row(
                children: [
                  Text(
                    ' ⚠ No olvides calentar antes de comenzar',
                    style: TextStyle(
                      color: Color(0XFF0f7991),
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              ...ejerciciosTiles,
              const SizedBox(height: 8.0),
              const Text(
                '⏱ Los descansos son muy importantes para realizar un buen entrenamiento',
                style: TextStyle(
                  color: Color(0XFF0f7991),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                ),
              ),
              const Divider(
                height: 25,
              ),
            ],
          ),
        );
      }
    });

    return Column(
      children: tiles,
    );
  }
}
