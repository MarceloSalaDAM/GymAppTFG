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
    final diasOrdenados = [
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO',
      'DOMINGO'
    ];

    final diasPresentes = diasOrdenados.where((dia) {
      return widget.rutina.dias.containsKey(dia);
    }).toList();

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
      body: Center(
        child: Container(
          height: 800,
          margin: EdgeInsets.fromLTRB(15, 25, 15, 90),
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: PageView.builder(
            itemCount: diasPresentes.length,
            itemBuilder: (context, index) {
              final diaEnMayusculas = diasPresentes[index];
              final dias = widget.rutina.dias;
              final ejerciciosDia = dias[diaEnMayusculas];

              return Container(
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 4),
                  borderRadius: BorderRadius.circular(18),
                ),
                constraints: BoxConstraints(maxHeight: 800),
                child: SingleChildScrollView(
                  child: _buildDia(diaEnMayusculas, ejerciciosDia),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDia(String dia, Map<String, dynamic> ejerciciosDia) {
    List<Widget> ejerciciosTiles = [];

    if (ejerciciosDia['ejercicios'] != null) {
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
                  print("Botón de edición presionado para $dia");
                  editModeByDay[dia] = !(editModeByDay[dia] ?? false);
                  if (editModeByDay[dia]!) {
                    // Si está entrando en modo edición, copia la lista completa de ejercicios
                    editingExercisesByDay[dia] =
                        List.from(ejerciciosDia['ejercicios'] as List);
                  } else {
                    // Si está saliendo de modo edición, restablece a null
                    editingExercisesByDay[dia] = [];
                  }
                });
              },
              icon: Icon(Icons.edit),
              color: const Color(0XFF0f7991),
            ),
          ],
        ),
      );

      for (var ejercicio in ejerciciosDia['ejercicios']) {
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
              if (editModeByDay[dia] == true)
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
                            print("Guardando cambios para $dia");
                            setState(() {
                              editModeByDay[dia] = false;
                              ejerciciosDia['ejercicios'] =
                                  List.from(editingExercisesByDay[dia] ?? []);
                            });
                          },
                          child: Text('Guardar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print("Cancelando cambios para $dia");
                            setState(() {
                              editModeByDay[dia] = false;
                              editingExercisesByDay[dia] = [];
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
              Divider( // Agrega un Divider
                height: 20,
                color: Colors.grey,
              ),
            ],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dia,
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
        const Text(
          '⏱ Los descansos son muy importantes para realizar un buen entrenamiento',
          style: TextStyle(
            color: Color(0XFF0f7991),
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
          ),
        ),
        const SizedBox(height: 8.0),
        ...ejerciciosTiles,
      ],
    );
  }
}
