import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  PageController _pageController = PageController();
  Map<String, bool> editModeByDay = {};
  Map<String, List<Map<String, dynamic>>> editingExercisesByDay = {};
  FirebaseFirestore db = FirebaseFirestore.instance;

  void _guardarCambiosEnFirebase(String dia) async {
    try {
      // Obtén el ID del usuario actual
      String? idUser = FirebaseAuth.instance.currentUser?.uid;

      // Verifica que el ID del usuario esté presente antes de proceder
      if (idUser == null) {
        print('Error: ID de usuario no disponible');
        return;
      }

      // Obtenemos una referencia al documento del usuario en Firebase
      final userDocRef =
          FirebaseFirestore.instance.collection('usuarios').doc(idUser);

      // Obtenemos una referencia a la subcolección de rutinas
      final rutinasCollectionRef = userDocRef.collection('rutinas');

      // Obtenemos una referencia al documento de la rutina en Firebase
      final rutinaRef = rutinasCollectionRef.doc(widget.rutina.id);

      // Obtenemos la información actual de la rutina desde Firebase
      final rutinaSnapshot = await rutinaRef.get();

      // Verificamos si el día que estamos editando existe en la base de datos
      if (rutinaSnapshot.exists &&
          rutinaSnapshot.data()!['dias'][dia] != null) {
        // Actualizamos los datos del día en la base de datos
        await rutinaRef.update({
          'dias.$dia.ejercicios': editingExercisesByDay[dia],
        });

        // Notificamos al usuario que los cambios se guardaron exitosamente
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Cambios guardados correctamente'),
        ));
      } else {
        // Manejar el caso en el que el día no existe en la base de datos
        print('El día $dia no existe en la base de datos');
      }
    } catch (error) {
      // Manejar cualquier error que pueda ocurrir durante la actualización en Firebase
      print('Error al guardar cambios en Firebase: $error');
      // También puedes mostrar un SnackBar indicando el error al usuario si lo prefieres
    }
  }

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
            controller: _pageController,
            physics: editModeByDay.containsValue(true)
                ? NeverScrollableScrollPhysics()
                : AlwaysScrollableScrollPhysics(),
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
      // Botones fuera del contenedor del PageView
      persistentFooterButtons: [
        Visibility(
          visible: editModeByDay.containsValue(true),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF0f7991),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    'CANCELAR',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("Guardando cambios");
                  // Iteramos sobre los días en modo de edición
                  editModeByDay.forEach((dia, isEditMode) {
                    if (isEditMode) {
                      _guardarCambiosEnFirebase(dia);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF0f7991),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    'GUARDAR',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
                          for (var ej in editingExercisesByDay[dia]!) {
                            ej['series'] = int.parse(value);
                          }
                        });
                      },
                      decoration: InputDecoration(labelText: 'Series'),
                    ),
                    TextFormField(
                      initialValue: ejercicio['repeticiones'].toString(),
                      onChanged: (value) {
                        setState(() {
                          print("Cambiando repeticiones: $value");
                          for (var ej in editingExercisesByDay[dia]!) {
                            ej['repeticiones'] = int.parse(value);
                          }
                        });
                      },
                      decoration: InputDecoration(labelText: 'Repeticiones'),
                    ),
                    TextFormField(
                      initialValue: ejercicio['peso'].toString(),
                      onChanged: (value) {
                        setState(() {
                          print("Cambiando peso: $value");
                          for (var ej in editingExercisesByDay[dia]!) {
                            ej['peso'] = double.parse(value);
                          }
                        });
                      },
                      decoration: InputDecoration(labelText: 'Peso (kg)'),
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
              Divider(
                // Agrega un Divider
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
