import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_objects/rutinas_firebase.dart';
import 'dart:async';

class DetallesRutinaView extends StatefulWidget {
  Rutina rutina;

  DetallesRutinaView({required this.rutina});

  @override
  _DetallesRutinaViewState createState() => _DetallesRutinaViewState();
}

class _DetallesRutinaViewState extends State<DetallesRutinaView> {
  PageController _pageController = PageController();
  Map<String, bool> editModeByDay = {};
  Map<String, List<Map<String, dynamic>>> editingExercisesByDay = {};
  FirebaseFirestore db = FirebaseFirestore.instance;
  int currentPage = 0;
  bool isTimerRunning = false; // Variable para controlar el cronómetro
  Timer? _timer; // Objeto Timer para el cronómetro
  int _start = 0; // Tiempo inicial en segundos para el cronómetro

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

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el cronómetro al salir del widget
    super.dispose();
  }

  void startTimer() {
    const oneMillisecond = Duration(milliseconds: 1);
    _timer = Timer.periodic(
      oneMillisecond,
      (Timer timer) {
        setState(() {
          _start++; // Incrementar el tiempo transcurrido en milisegundos
        });
      },
    );
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  void resetTimer() {
    setState(() {
      _start = 10;
      isTimerRunning = false;
    });
    stopTimer();
  }

  void _guardarCambiosEnFirebase(String dia) async {
    try {
      // Código para guardar cambios en Firebase
    } catch (error) {
      print('Error al guardar cambios en Firebase: $error');
    }
  }

  void _loadOriginalData() async {
    try {
      // Código para cargar datos originales de la rutina
    } catch (e) {
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

    // En el lugar donde deseas mostrar el tiempo:
    String formatTime(int milliseconds) {
      int minutes = (milliseconds / (1000 * 60)).floor();
      int seconds = ((milliseconds / 1000) % 60).floor();
      int millis = (milliseconds % 1000).floor();
      return '$minutes:${seconds.toString().padLeft(2, '0')}:${millis.toString().padLeft(3, '0')}';
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
          height: 800,
          margin: EdgeInsets.fromLTRB(15, 25, 15, 50),
          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
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
              SizedBox(height: 16),
              Container(
                color: Colors.amber,
                child: Column(
                  children: [
                    if (!isTimerRunning) // Mostrar el botón "Comenzar" solo si el tiempo no está corriendo
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isTimerRunning = true;
                            startTimer();
                          });
                        },
                        child: Text(
                          'COMENZAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isTimerRunning) // Mostrar el botón "Finalizar Sesión" solo si el tiempo está corriendo
                      ElevatedButton(
                        onPressed: () {
                          // Coloca aquí la lógica para finalizar la sesión
                        },
                        child: Text(
                          'FINALIZAR SESIÓN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isTimerRunning) // Mostrar el botón "Abandonar" solo si el tiempo está corriendo
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isTimerRunning = false; // Detener el cronómetro
                            resetTimer(); // Reiniciar el cronómetro
                          });
                        },
                        child: Text(
                          'ABANDONAAAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    // Mostrar el tiempo restante si el cronómetro está corriendo
                    if (isTimerRunning)
                      Text(
                        '${formatTime(_start)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              )
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
                      decoration: InputDecoration(labelText: 'Series'),
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
                      decoration: InputDecoration(labelText: 'Repeticiones'),
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
                      decoration: InputDecoration(labelText: 'Peso (kg)'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '\t\t\tSeries: ',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic),
                        ),
                        Text(
                          '${ejercicio['series']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '\t\t\tRepeticiones: ',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic),
                        ),
                        Text(
                          '${ejercicio['repeticiones']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '\t\t\tPeso: ',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          '${ejercicio['peso']} kg',
                          style: TextStyle(
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
