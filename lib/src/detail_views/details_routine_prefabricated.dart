import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../firebase_objects/rutinas_predeterminadas_firebase.dart';

class DetallesRutinaPredeterminadaView extends StatelessWidget {
  final String idPred; // Cambiado a String
  final FirebaseFirestore db = FirebaseFirestore.instance;

  DetallesRutinaPredeterminadaView({required this.idPred});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getRutinaFromFirebase(), // Llamada a la función para obtener la rutina desde Firebase
      builder: (context, AsyncSnapshot<RutinaPredeterminada> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mientras se carga, puedes mostrar un indicador de carga o algo similar
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // En caso de error, puedes manejarlo aquí
          return Text('Error: ${snapshot.error}');
        } else {
          // Cuando la carga es exitosa, muestras la información de la rutina
          RutinaPredeterminada rutina = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0XFF0f7991),
              title: Text(
                '${rutina.nombreRutinaPred}',
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
                    _buildDiasList(rutina.diasPred),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<RutinaPredeterminada> _getRutinaFromFirebase() async {
    // Realiza la consulta a Firebase utilizando el ID de la rutina
    DocumentSnapshot rutinaSnapshot =
    await db.collection('rutinas_predeterminadas').doc(idPred).get();

    // Crea la instancia de RutinaPredeterminada utilizando el factory constructor
    return RutinaPredeterminada.fromFirestore(rutinaSnapshot);
  }

  Widget _buildDiasList(Map<String, dynamic> dias) {
    List<Widget> tiles = [];

    dias.forEach((nombreDia, infoDia) {
      List<Widget> ejerciciosTiles = [];

      if (infoDia['ejercicios'] != null) {
        ejerciciosTiles.add(
          const Column(
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

        for (var ejercicio in infoDia['ejercicios']) {
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
              nombreDia,
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
    });

    return Column(
      children: tiles,
    );
  }
}
