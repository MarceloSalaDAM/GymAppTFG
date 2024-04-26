import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../detail_views/details_routine.dart';
import '../firebase_objects/rutinas_firebase.dart';

class EjerciciosDiaView extends StatefulWidget {
  final String dia;
  final String rutinaId;
  final Map<String, dynamic> ejerciciosDia;

  const EjerciciosDiaView({
    super.key,
    required this.dia,
    required this.rutinaId,
    required this.ejerciciosDia,
  });

  @override
  _EjerciciosDiaViewState createState() => _EjerciciosDiaViewState();
}

class _EjerciciosDiaViewState extends State<EjerciciosDiaView> {
  final Map<int, bool> _expandedState = {};
  final Map<int, TextEditingController> _pesoControllers = {};
  final Map<int, TextEditingController> _seriesControllers = {};
  final Map<int, TextEditingController> _repeticionesControllers = {};
  final Set<int> _ejerciciosEliminados = {};
  String selectedSeries = '1';
  String selectedRepeticiones = '1';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEjercicios();
  }

  void _initializeControllers(List<dynamic> ejerciciosDia) {
    _pesoControllers.clear();
    _seriesControllers.clear();
    _repeticionesControllers.clear();
    for (int index = 0; index < (ejerciciosDia ?? []).length; index++) {
      final peso = ejerciciosDia[index]['peso'] ?? '';
      final series = ejerciciosDia[index]['series'] ?? '';
      final repeticiones = ejerciciosDia[index]['repeticiones'] ?? '';
      _pesoControllers[index] = TextEditingController(text: '$peso');
      _seriesControllers[index] = TextEditingController(text: '$series');
      _repeticionesControllers[index] =
          TextEditingController(text: '$repeticiones');
    }
  }

  Future<void> _loadEjercicios() async {
    setState(() {
      _loading = true;
    });

    Timer(const Duration(seconds: 1), () async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userDoc =
              FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
          final doc =
              await userDoc.collection('rutinas').doc(widget.rutinaId).get();
          final ejerciciosDia = doc.data()?['dias'][widget.dia]['ejercicios'];

          _initializeControllers(ejerciciosDia);

          setState(() {
            _loading = false;
            widget.ejerciciosDia['ejercicios'] = ejerciciosDia;
          });
        }
      } catch (error) {
        print('Error al cargar los ejercicios: $error');
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pesoControllers.forEach((index, controller) {
      controller.dispose();
    });
    _seriesControllers.forEach((index, controller) {
      controller.dispose();
    });
    _repeticionesControllers.forEach((index, controller) {
      controller.dispose();
    });

    super.dispose();
  }

  Future<void> _eliminarEjercicio(String rutinaId, int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
        await userDoc.collection('rutinas').doc(rutinaId).update({
          'dias.${widget.dia}.ejercicios': FieldValue.arrayRemove(
              [widget.ejerciciosDia['ejercicios'][index]])
        });
        setState(() {
          widget.ejerciciosDia['ejercicios'].removeAt(index);
        });
        print('Ejercicio eliminado exitosamente de la rutina del usuario.');
      } else {
        print('Error: Usuario no logueado.');
      }
    } catch (error) {
      print('Error al eliminar el ejercicio de la rutina del usuario: $error');
    }
  }

  void _actualizarEjercicio(
    String series,
    String peso,
    String repeticiones,
    int index,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final rutinaId = widget.rutinaId;
      final dia = widget.dia;
      final ejercicios = List.from(widget.ejerciciosDia['ejercicios']);
      final ejercicio = ejercicios[index];
      ejercicio['series'] = series;
      ejercicio['peso'] = peso;
      ejercicio['repeticiones'] = repeticiones;

      userDoc.collection('rutinas').doc(rutinaId).update({
        'dias.$dia.ejercicios': ejercicios,
      }).then((_) {
        _loadEjercicios();
      }).catchError((error) {
        print('Error al actualizar el ejercicio: $error');
      });
    }
  }

  void _agregarEjercicio() {
    // Implementar la lógica para añadir ejercicio aquí
  }

  void _crearEjercicio() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nombre = '';
        String peso = '';
        final nombreController = TextEditingController();
        final pesoController = TextEditingController();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            height: 700,
            width: 450,
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: 3.0,
              ),
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'CREAR EJERCICIO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18.0),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre ejercicio',
                        labelStyle: TextStyle(fontSize: 19.0),
                      ),
                      onChanged: (value) => nombre = value,
                    ),
                    const SizedBox(height: 18.0),
                    TextField(
                      controller: pesoController,
                      decoration: const InputDecoration(
                        labelText: 'Peso',
                        labelStyle: TextStyle(fontSize: 19.0),
                      ),
                      onChanged: (value) => peso = value,
                    ),
                    const SizedBox(height: 38.0),
                    DropdownButtonFormField<String>(
                      value: selectedSeries,
                      onChanged: (value) {
                        setState(() {
                          selectedSeries = value ?? '1';
                        });
                      },
                      items: List.generate(20, (index) {
                        return DropdownMenuItem<String>(
                          value: (index + 1).toString(),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        );
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Series',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 22.0),
                      ),
                    ),
                    const SizedBox(height: 18.0),
                    DropdownButtonFormField<String>(
                      value: selectedRepeticiones,
                      onChanged: (value) {
                        setState(() {
                          selectedRepeticiones = value ?? '1';
                        });
                      },
                      items: List.generate(20, (index) {
                        return DropdownMenuItem<String>(
                          value: (index + 1).toString(),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        );
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Repeticiones',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 22.0),
                      ),
                    ),
                    const Divider(height: 50.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF0f7991),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 0.0),
                            child: Text(
                              'CANCELAR',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (nombreController.text.isEmpty ||
                                pesoController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Error',
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    content: const Text(
                                      'Por favor, completa todos los campos.',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0XFF0f7991),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 2.0),
                                          child: Text(
                                            'ACEPTAR',
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              _guardarEjercicio(
                                nombreController.text,
                                selectedSeries,
                                selectedRepeticiones,
                                pesoController.text,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF0f7991),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 2.0),
                            child: Text(
                              'GUARDAR',
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _loadEjercicios();
    });
  }

  void _guardarEjercicio(
      String nombre, String series, String peso, String repeticiones) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      userDoc.collection('rutinas').doc(widget.rutinaId).update({
        'dias.${widget.dia}.ejercicios': FieldValue.arrayUnion([
          {
            'nombre': nombre,
            'series': series,
            'peso': peso,
            'repeticiones': repeticiones,
          }
        ])
      }).then((_) {
        _loadEjercicios();
      }).catchError((error) {
        print('Error al guardar el ejercicio: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        title: Text(
          'EDITAR ${widget.dia}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Icono de retroceso
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        (widget.ejerciciosDia['ejercicios'] ?? []).length,
                    itemBuilder: (context, index) {
                      final pesoController =
                          _pesoControllers[index] ?? TextEditingController();
                      final seriesController =
                          _seriesControllers[index] ?? TextEditingController();
                      final repeticionesController =
                          _repeticionesControllers[index] ??
                              TextEditingController();

                      return Card(
                        elevation: 3.0,
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side:
                              BorderSide(color: Colors.grey[400]!, width: 1.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.ejerciciosDia['ejercicios'][index]['nombre']}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                style: const TextStyle(fontSize: 20),
                                decoration: const InputDecoration(
                                    labelText: 'Peso (kg)',
                                    labelStyle: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                controller: pesoController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                style: const TextStyle(fontSize: 20),
                                decoration: const InputDecoration(
                                    labelText: 'Series',
                                    labelStyle: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                controller: seriesController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                style: const TextStyle(fontSize: 20),
                                decoration: const InputDecoration(
                                    labelText: 'Repeticiones',
                                    labelStyle: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                controller: repeticionesController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 30, color: Colors.black),
                                    onPressed: () {
                                      _eliminarEjercicio(
                                          widget.rutinaId, index);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.save,
                                        size: 30, color: Colors.black),
                                    onPressed: () {
                                      final int currentIndex = index;
                                      final peso = pesoController.text;
                                      final series = seriesController.text;
                                      final repeticiones =
                                          repeticionesController.text;

                                      print(
                                          'Peso: $peso, Series: $series, Repeticiones: $repeticiones');
                                      _actualizarEjercicio(series, peso,
                                          repeticiones, currentIndex);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Stack(
        children: [
          const BottomAppBar(
            color: Colors.transparent,
            elevation: 0,
          ),
          Container(
            height: kBottomNavigationBarHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0XFF0f7991), Color(0XFF4AB7D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, size: 30, color: Colors.white),
                  onPressed: _agregarEjercicio,
                ),
                IconButton(
                  icon: const Icon(Icons.create, size: 30, color: Colors.white),
                  onPressed: _crearEjercicio,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
