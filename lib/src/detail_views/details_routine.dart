import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  PageController _pageController = PageController();
  int currentPage = 0;
  String formattedTime = '';

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  Future<void> _subirDatosASesionFirebase(
      String formattedTime, String diaEnMayusculas) async {
    try {
      // Obtener el ID del usuario actual
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      // Verificar que el ID del usuario esté disponible
      if (userId != null) {
        // Obtener referencia al documento del usuario
        final userDocRef =
            FirebaseFirestore.instance.collection('usuarios').doc(userId);

        // Obtener referencia a la subcolección "sesiones" dentro del documento del usuario
        final sessionsCollectionRef = userDocRef.collection('sesiones');

        // Obtener el grupo correspondiente al día
        String grupo = widget.rutina.dias[diaEnMayusculas]['grupo'] ??
            ''; // Valor por defecto si no hay grupo
        // También puedes manejar si 'grupo' no está presente en todos los días o si es null

        // Subir los datos a la subcolección "sesiones"
        await sessionsCollectionRef.add({
          'fecha': DateTime.now(),
          'duracion': formattedTime,
          'grupo': grupo, // Agregar el grupo correspondiente al día
          'dia': diaEnMayusculas,
          // Guardar el día correspondiente
        });

        // Mostrar un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Datos de la sesión guardados en Firebase.'),
        ));
      } else {
        // Manejar el caso en el que el ID del usuario no esté disponible
        print('Error: ID de usuario no disponible.');
      }
    } catch (error) {
      // Manejar cualquier error que ocurra al subir los datos a Firebase
      print('Error al subir datos a Firebase: $error');
    }
  }

  String formatTime(int hours, int minutes, int seconds, int milliseconds) {
    String hoursStr = (hours % 24).toString().padLeft(
        2, '0'); // Si quieres contar horas más allá de 24, puedes quitar el %24
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String millisecondsStr = milliseconds.toString().padLeft(3, '0');

    return '$hoursStr:$minutesStr:$secondsStr:$millisecondsStr';
  }

  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);
    print('Rutina: ${widget.rutina}');
    print('Grupo: ${widget.rutina.grupo}');
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
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
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
                  physics: timerModel.isTimerRunning
                      ? NeverScrollableScrollPhysics()
                      : AlwaysScrollableScrollPhysics(),
                  itemCount: diasPresentes.length,
                  itemBuilder: (context, index) {
                    final diaEnMayusculas = diasPresentes[index];
                    final dias = widget.rutina.dias;
                    final ejerciciosDia = dias[diaEnMayusculas];

                    return Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                      decoration: BoxDecoration(
                        color: const Color( 0XFFF5F5DC),
                        border: Border.all(color: Colors.black, width: 4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      constraints: const BoxConstraints(maxHeight: 800),
                      child: SingleChildScrollView(
                        child: _buildDia(diaEnMayusculas, ejerciciosDia),
                      ),
                    );
                  },
                ),
              ),
              Visibility(
                visible: !timerModel.isTimerRunning,
                child: Row(
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
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
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
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const AlertDialog(
                                        title: Text(
                                          'TU RUTINA COMIENZA EN BREVES',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '⚠ Calienta bien antes de comenzar',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17.0,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Text(
                                              '⏱ Descansar al menos 2 minutos entre series',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ).then((value) {
                                    // Lógica a ejecutar después de cerrar el AlertDialog
                                    timerModel.startTimer();
                                  });
                                  Future.delayed(Duration(seconds: 3), () {
                                    if (mounted) {
                                      Navigator.of(context).pop();
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
                                      return const Text(
                                        textAlign: TextAlign.center,
                                        'Time Elapsed: Data not available',
                                        style: TextStyle(fontSize: 20),
                                      );
                                    }

                                    // Actualizar formattedTime globalmente
                                    formattedTime = formatTime(
                                        hours, minutes, seconds, milliseconds);

                                    print(
                                        '--------------->>>Time Elapsed: $formattedTime');

                                    return Text(
                                      textAlign: TextAlign.center,
                                      formattedTime,
                                      style: const TextStyle(
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
                                        final minutes =
                                            snapshot.data!['minutes'];
                                        final seconds =
                                            snapshot.data!['seconds'];
                                        final milliseconds =
                                            snapshot.data!['milliseconds'];

                                        if (hours == null ||
                                            minutes == null ||
                                            seconds == null ||
                                            milliseconds == null) {}

                                        // Actualizar formattedTime globalmente
                                        formattedTime = formatTime(hours,
                                            minutes, seconds, milliseconds);
                                        print(
                                            '--------------->>>Time Elapsed: $formattedTime');
                                        return ElevatedButton(
                                          onPressed: () async {
                                            timerModel.stopTimer();
                                            print(
                                                '--------------->>>Tiempo final: $formattedTime');
                                            // Subir los datos de la sesión a Firebase
                                            await _subirDatosASesionFirebase(
                                                formattedTime,
                                                diasPresentes[currentPage]);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.0, horizontal: 5.0),
                                            child: Text(
                                              'FINALIZAR\nSESIÓN',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                            },
                          ),
                          Consumer<TimerModel>(
                            builder: (context, timerModel, _) {
                              return !timerModel.isTimerRunning
                                  ? Container()
                                  : StreamBuilder<Map<String, dynamic>>(
                                      stream: backgroundTimer.dataStream,
                                      builder: (context, snapshot) {
                                        return ElevatedButton(
                                          onPressed: () {
                                            timerModel.stopTimer();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.0, horizontal: 5.0),
                                            child: Text(
                                              'ABANDONAR\nSESIÓN',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                            },
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
    );
  }

  Widget _buildDia(String dia, Map<String, dynamic> ejerciciosDia) {
    List<Widget> exerciseTables = [];
    if (ejerciciosDia['ejercicios'] != null) {
      for (var ejercicio in ejerciciosDia['ejercicios']) {
        String nombreEjercicio = ejercicio['nombre'];
        List<String> nombreEjercicioWords = nombreEjercicio.split(' ');
        List<Widget> nombreEjercicioWidgets = [];
        int index = 0;

        while (index < nombreEjercicioWords.length) {
          List<String> currentLineWords = nombreEjercicioWords
              .skip(index)
              .take(3)
              .toList(); // Tomar las siguientes tres palabras
          nombreEjercicioWidgets.add(Text(
            currentLineWords.join(' '),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19, // Tamaño de fuente más grande para el título
              color: Colors.black,
            ),
          )); // Unirlas en una sola línea
          index += 3;
        }
        Widget exerciseTable = DataTable(
          horizontalMargin: 5,
          columnSpacing: 0.0,
          dataRowMaxHeight: 60,
          columns: [
            DataColumn(
              label: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: nombreEjercicioWidgets,
              ),
            ),
            const DataColumn(
              label: Text(''), // Texto vacío en la segunda celda
            ),
          ],
          rows: [
            DataRow(cells: [
              const DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Peso (kg)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Tamaño de fuente para los valores
                        color: Colors.black, // Color de los valores
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${ejercicio['peso']}',
                      style: const TextStyle(
                        fontSize: 18, // Tamaño de fuente para los valores
                        color: Colors.black, // Color de los valores
                      ),
                      textAlign:
                          TextAlign.right, // Alinear el valor a la derecha
                    ),
                  ],
                ),
              ),
            ]),
            DataRow(cells: [
              const DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Series',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Tamaño de fuente para los valores
                        color: Colors.black, // Color de los valores
                      ),
                      textAlign:
                          TextAlign.right, // Alinear el valor a la derecha
                    ),
                  ],
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${ejercicio['series']}',
                      style: const TextStyle(
                        fontSize: 18, // Tamaño de fuente para los valores
                        color: Colors.black, // Color de los valores
                      ),
                      textAlign:
                          TextAlign.right, // Alinear el valor a la derecha
                    ),
                  ],
                ),
              ),
            ]),
            DataRow(cells: [
              const DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Repeticiones',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Tamaño de fuente para los valores
                      color: Colors.black, // Color de los valores
                    ),
                    textAlign: TextAlign.right, // Alinear el valor a la derecha
                  ),
                ],
              )),
              DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${ejercicio['repeticiones']}',
                      style: const TextStyle(
                        fontSize: 18, // Tamaño de fuente para los valores
                        color: Colors.black, // Color de los valores
                      ),
                      textAlign:
                          TextAlign.right, // Alinear el valor a la derecha
                    ),
                  ])),
            ]),
          ],
        );
        exerciseTables.add(
          Container(
            margin: EdgeInsets.only(bottom: 26.0), // Espacio entre las tablas
            child: exerciseTable,
          ),
        );
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dia,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,
                decoration: TextDecoration.underline),
          ),
          const SizedBox(height: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: exerciseTables,
          ),
        ],
      ),
    );
  }
}
