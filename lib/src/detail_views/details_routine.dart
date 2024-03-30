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

  // Método para subir los datos de la sesión a Firebase
  Future<void> _subirDatosASesionFirebase(String formattedTime) async {
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

        // Subir los datos a la subcolección "sesiones"
        await sessionsCollectionRef.add({
          'fecha': DateTime.now(),
          'duracion': formattedTime,
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
                  physics: timerModel.isTimerRunning
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
              const SizedBox(height: 20),
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
                                                formattedTime);
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
                                          onPressed: () {
                                            timerModel.stopTimer();
                                            print(
                                                '--------------->>>Tiempo final: $formattedTime');
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
    List<Widget> exerciseWidgets = [];

    if (ejerciciosDia['ejercicios'] != null) {
      for (var ejercicio in ejerciciosDia['ejercicios']) {
        exerciseWidgets.add(
          Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ejercicio['nombre'],
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Series: ${ejercicio['series']}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Reps: ${ejercicio['repeticiones']}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Peso: ${ejercicio['peso']}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dia,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27.0),
          ),
          SizedBox(height: 8.0),
          ...exerciseWidgets,
        ],
      ),
    );
  }
}
