import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';
import '../custom/timer.dart';
import '../custom/timer_provider.dart';
import '../firebase_objects/rutinas_firebase.dart';
import 'dart:async';

final BackgroundTimer backgroundTimer = BackgroundTimer();

class DetallesRutinaView extends StatefulWidget {
  Rutina rutina;

  DetallesRutinaView({required this.rutina});

  @override
  _DetallesRutinaViewState createState() => _DetallesRutinaViewState();
}

class _DetallesRutinaViewState extends State<DetallesRutinaView> {
  late Function() onStart;
  PageController _pageController = PageController();
  Map<String, bool> editModeByDay = {};
  Map<String, List<Map<String, dynamic>>> editingExercisesByDay = {};
  int currentPage = 0;
  bool isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _loadOriginalData();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  void _guardarCambiosEnFirebase(String dia) async {
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
    if (rutinaSnapshot.exists && rutinaSnapshot.data()!['dias'][dia] != null) {
      // Actualizamos los datos del día en la base de datos
      List<Map<String, dynamic>> updatedExercises = [];
      for (var exercise in editingExercisesByDay[dia]!) {
        // Si el ejercicio está siendo editado y se ha cambiado el peso
        if (exercise['nombre'] != null && exercise['peso'] != null) {
          updatedExercises.add({
            'nombre': exercise['nombre'],
            'series': exercise['series'],
            'repeticiones': exercise['repeticiones'],
            'peso': exercise['peso'], // Actualizamos el peso aquí
          });
        }
      }
      await rutinaRef.update({
        'dias.$dia.ejercicios': updatedExercises,
      });
      // Salir del modo de edición para el día específico
      setState(() {
        editModeByDay[dia] = false;
      });
      // Notificamos al usuario que los cambios se guardaron exitosamente
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('RUTINA ACTUALIZADA CORRECTAMENTE'),
      ));
    } else {
      // Manejar el caso en el que el día no existe en la base de datos
      print('El día $dia no existe en la base de datos');
    }
  }

  void _loadOriginalData() async {
    try {
      Rutina rutina = await widget.rutina.obtenerRutinaActual();
      setState(() {
        // Asigna la rutina original y restablece el estado de edición
        widget.rutina = rutina;
        editModeByDay = {};
        editingExercisesByDay = {};
      });
      // Código para cargar datos originales de la rutina
    } catch (e) {
      // Maneja el error según tus necesidades
      print("Error al cargar la rutina original: $e");
    }
  }

  void _resetData() {
    setState(() {
      editModeByDay = {};
      editingExercisesByDay = {};
    });

    _loadOriginalData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('NO SE GUARDARON LOS CAMBIOS'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);
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

    String formatTime(int hours, int minutes, int seconds, int milliseconds) {
      String hoursStr = (hours % 24).toString().padLeft(2,
          '0'); // Si quieres contar horas más allá de 24, puedes quitar el %24
      String minutesStr = minutes.toString().padLeft(2, '0');
      String secondsStr = seconds.toString().padLeft(2, '0');
      String millisecondsStr = milliseconds.toString().padLeft(3, '0');

      return '$hoursStr:$minutesStr:$secondsStr:$millisecondsStr';
    }

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
          height: 2000,
          margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      currentPage = page;
                    });
                  },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(diasPresentes.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(index,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      child: CircleAvatar(
                        backgroundColor:
                            currentPage == index ? Colors.black : Colors.grey,
                        radius: currentPage == index ? 15 : 10,
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Consumer<TimerModel>(
                          builder: (context, timerModel, _) {
                            return Visibility(
                              visible: !timerModel.isTimerRunning,
                              child: ElevatedButton(
                                onPressed: () {
                                  timerModel.startTimer();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0XFF0f7991),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Text(
                                    'INICIAR SESIÓN',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Espacio entre el botón y el texto
                      Consumer<TimerModel>(
                        builder: (context, timerModel, _) {
                          return !timerModel.isTimerRunning
                              ? Container()
                              : StreamBuilder<Map<String, dynamic>>(
                                  stream: backgroundTimer.dataStream,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return Container();
                                    }
                                    final hours = snapshot.data!['hours'];
                                    final minutes = snapshot.data!['minutes'];
                                    final seconds = snapshot.data!['seconds'];
                                    final milliseconds =
                                        snapshot.data!['milliseconds'];

                                    if (hours == null ||
                                        minutes == null ||
                                        seconds == null ||
                                        milliseconds == null) {
                                      return Text(
                                        textAlign: TextAlign.center,
                                        'Time Elapsed: Data not available',
                                        style: TextStyle(fontSize: 20),
                                      );
                                    }

                                    final formattedTime = formatTime(
                                        hours, minutes, seconds, milliseconds);

                                    return Text(
                                      textAlign: TextAlign.center,
                                      '$formattedTime',
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    );
                                  },
                                );
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (timerModel.isTimerRunning)
                            ElevatedButton(
                              onPressed: () {
                                timerModel.stopTimer();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 5.0),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'FINALIZAR\nSESIÓN',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          if (timerModel.isTimerRunning)
                            ElevatedButton(
                              onPressed: () {
                                timerModel.stopTimer();
                              },
                              style: ElevatedButton.styleFrom(
                                alignment: Alignment.center,
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 0.0),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'ABANDONAR\nSESIÓN',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Espacio entre el texto y los botones
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Visibility(
          visible: editModeByDay.containsValue(true),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _resetData();
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
                    'CANCELAR',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("Guardando cambios");
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
                      color: Colors.white,
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
            Text(
              'Ejercicios',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  editModeByDay[dia] = !(editModeByDay[dia] ?? false);
                  if (editModeByDay[dia]!) {
                    editingExercisesByDay[dia] =
                        List.from(ejerciciosDia['ejercicios'] as List);
                  } else {
                    editingExercisesByDay[dia] = [];
                    _resetData();
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
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (editModeByDay[dia] == true)
                Column(
                  children: [
                    TextFormField(
                      initialValue: ejercicio['series'].toString(),
                      onChanged: (value) {
                        setState(() {
                          var ejercicioActual = editingExercisesByDay[dia]!
                              .firstWhere(
                                  (e) => e['nombre'] == ejercicio['nombre']);
                          ejercicioActual['series'] = int.parse(value);
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Series'),
                    ),
                    TextFormField(
                      initialValue: ejercicio['repeticiones'].toString(),
                      onChanged: (value) {
                        setState(() {
                          var ejercicioActual = editingExercisesByDay[dia]!
                              .firstWhere(
                                  (e) => e['nombre'] == ejercicio['nombre']);
                          ejercicioActual['repeticiones'] = int.parse(value);
                        });
                      },
                      decoration:
                          const InputDecoration(labelText: 'Repeticiones'),
                    ),
                    TextFormField(
                      initialValue: ejercicio['peso'].toString(),
                      onChanged: (value) {
                        setState(() {
                          var ejercicioActual = editingExercisesByDay[dia]!
                              .firstWhere(
                                  (e) => e['nombre'] == ejercicio['nombre']);
                          ejercicioActual['peso'] = double.parse(value);
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    ),
                  ],
                )
              else
                Column(
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
