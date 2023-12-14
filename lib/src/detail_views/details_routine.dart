import 'package:flutter/material.dart';
import '../firebase_objects/rutinas_firebase.dart';
import 'edit_routine.dart';

class DetallesRutinaView extends StatefulWidget {
  final Rutina rutina;

  const DetallesRutinaView({required this.rutina});

  @override
  _DetallesRutinaViewState createState() => _DetallesRutinaViewState();
}

class _DetallesRutinaViewState extends State<DetallesRutinaView> {
  Map<String, bool> editModeByDay = {};
  Map<String, List<Map<String, dynamic>>> editingExercisesByDay = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        title: Text(
          '${widget.rutina.nombreRutina}',
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
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.all(10.0),
                children: [
                  _buildDiasList(widget.rutina.dias, context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiasList(Map<String, dynamic> dias, BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ejercicios',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                // Botón de editar para la lista de ejercicios del día
                IconButton(
                  onPressed: () {
                    setState(() {
                      print("Botón de edición presionado para $diaEnMayusculas");
                      editModeByDay[diaEnMayusculas] =
                      !(editModeByDay[diaEnMayusculas] ?? false);
                      if (editModeByDay[diaEnMayusculas]!) {
                        // Si está entrando en modo edición, copia la lista completa de ejercicios
                        editingExercisesByDay[diaEnMayusculas] =
                            List.from(dias[diaEnMayusculas]['ejercicios'] as List);
                      } else {
                        // Si está saliendo de modo edición, restablece a null
                        editingExercisesByDay[diaEnMayusculas] = [];
                      }
                    });
                  },
                  icon: Icon(Icons.edit),
                  color: const Color(0XFF0f7991),
                ),
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
                  if (editModeByDay[diaEnMayusculas] == true)
                  // Campos de edición para el modo de edición
                    Column(
                      children: [
                        TextFormField(
                          initialValue: ejercicio['series'].toString(),
                          onChanged: (value) {
                            setState(() {
                              print("Cambiando series: $value");
                              ejercicio['series'] = int.parse(value);
                            });
                          },
                          decoration: InputDecoration(labelText: 'Series'),
                        ),
                        TextFormField(
                          initialValue: ejercicio['repeticiones'].toString(),
                          onChanged: (value) {
                            setState(() {
                              print("Cambiando repeticiones: $value");
                              ejercicio['repeticiones'] = int.parse(value);
                            });
                          },
                          decoration: InputDecoration(labelText: 'Repeticiones'),
                        ),
                        TextFormField(
                          initialValue: ejercicio['peso'].toString(),
                          onChanged: (value) {
                            setState(() {
                              print("Cambiando peso: $value");
                              ejercicio['peso'] = double.parse(value);
                            });
                          },
                          decoration: InputDecoration(labelText: 'Peso (kg)'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                print("Guardando cambios para $diaEnMayusculas");
                                setState(() {
                                  editModeByDay[diaEnMayusculas] = false;
                                  dias[diaEnMayusculas]['ejercicios'] =
                                      List.from(editingExercisesByDay[diaEnMayusculas] ?? []);
                                });
                              },
                              child: Text('Guardar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                print("Cancelando cambios para $diaEnMayusculas");
                                setState(() {
                                  editModeByDay[diaEnMayusculas] = false;
                                  editingExercisesByDay[diaEnMayusculas] = [];
                                });
                              },
                              child: Text('Cancelar'),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      // Visualización normal del ejercicio
                      children: [
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

    return Column(children: [...tiles]);
  }
}
