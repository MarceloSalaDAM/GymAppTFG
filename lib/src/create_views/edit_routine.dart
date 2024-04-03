import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EjerciciosDiaView extends StatefulWidget {
  final String dia;
  final String rutinaId;
  final StreamController<void> _streamController = StreamController<void>();
  final Map<String, dynamic> ejerciciosDia;

  EjerciciosDiaView({
    required this.dia,
    required this.rutinaId, required this.ejerciciosDia,
  });

  @override
  _EjerciciosDiaViewState createState() => _EjerciciosDiaViewState();
}

class _EjerciciosDiaViewState extends State<EjerciciosDiaView> {
  Map<int, bool> _expandedState = {};
  Map<int, TextEditingController> _pesoControllers = {};
  Map<int, TextEditingController> _seriesControllers = {};
  Map<int, TextEditingController> _repeticionesControllers = {};
  Set<int> _ejerciciosEliminados = {};
  String selectedSeries = '1';
  String selectedRepeticiones = '1';

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los valores reales de los ejercicios
    for (int index = 0;
    index < (widget.ejerciciosDia['ejercicios'] ?? []).length;
    index++) {
      final peso = widget.ejerciciosDia['ejercicios'][index]['peso'] ?? '';
      final series = widget.ejerciciosDia['ejercicios'][index]['series'] ?? '';
      final repeticiones =
          widget.ejerciciosDia['ejercicios'][index]['repeticiones'] ?? '';
      _pesoControllers[index] = TextEditingController(text: '$peso');
      _seriesControllers[index] = TextEditingController(text: '$series');
      _repeticionesControllers[index] =
          TextEditingController(text: '$repeticiones');
    }
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se elimina
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
      // Accede al documento del usuario logueado
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
        FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
        // Elimina el ejercicio del día en la subcolección de rutinas del usuario
        await userDoc.collection('rutinas').doc(rutinaId).update({
          'dias.${widget.dia}.ejercicios': FieldValue.arrayRemove(
              [widget.ejerciciosDia['ejercicios'][index]])
        });
        setState(() {
          // Solo eliminamos el ejercicio correspondiente al índice proporcionado
          widget.ejerciciosDia['ejercicios'].removeAt(index);
        });
        print('Ejercicio eliminado exitosamente de la rutina del usuario.');
      } else {
        print('Error: Usuario no logueado.');
      }
      widget._streamController.add(null);
    } catch (error) {
      print('Error al eliminar el ejercicio de la rutina del usuario: $error');
    }
  }

  void _agregarEjercicio() {
    // Implementa la lógica para añadir ejercicio aquí
    // Esta parte se completará más adelante
  }

  void _crearEjercicio() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String nombre = '';
        String peso = '';
        // Define los controladores de texto
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
            padding: EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white,
              border: Border.all(
                color: Colors.black, // Color del borde
                width: 3.0, // Ancho del borde
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
                      decoration: InputDecoration(
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
                            style: TextStyle(
                                fontSize:
                                18.0), // Cambia el tamaño de fuente aquí
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
                            style: TextStyle(fontSize: 18.0),
                          ),
                        );
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Repeticiones',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                            fontSize:
                            22.0), // Cambia el tamaño de fuente de la etiqueta aquí
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
                            // Valida todos los campos de texto antes de guardar el ejercicio
                            if (nombreController.text.isEmpty ||
                                pesoController.text.isEmpty) {
                              // Si algún campo está vacío, muestra un AlertDialog con un mensaje de error
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
                              // Si todos los campos están completos, guarda el ejercicio y cierra el diálogo
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
    );
  }

  Future<void> _guardarEjercicio(
      String nombre, String series, String peso, String repeticiones) async {
    // Aquí se debe guardar el ejercicio en Firebase
    // Puedes usar FirebaseFirestore para añadir el nuevo ejercicio a la colección correspondiente
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
      });
      widget._streamController.add(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dia} Ejercicios'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<void>(
              stream: widget._streamController.stream,
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: (widget.ejerciciosDia['ejercicios'] ?? []).length,
                  itemBuilder: (context, index) {
                    final isExpanded = _expandedState[index] ?? false;

                    // Verifica si el índice está en la lista de ejercicios eliminados
                    if (_ejerciciosEliminados.contains(index)) {
                      return SizedBox.shrink();
                    }

                    return Card(
                      child: ExpansionTile(
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _expandedState[index] = expanded;
                          });
                        },
                        title: Text(
                          widget.ejerciciosDia['ejercicios'][index]['nombre'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        initiallyExpanded: isExpanded,
                        children: isExpanded
                            ? [
                          ListTile(
                            title: TextField(
                              decoration:
                              InputDecoration(labelText: 'Peso (kg)'),
                              controller: _pesoControllers[index],
                              onChanged: (value) {
                                // Manejar los cambios en el campo de peso aquí
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          ListTile(
                            title: TextField(
                              decoration:
                              InputDecoration(labelText: 'Series'),
                              controller: _seriesControllers[index],
                              onChanged: (value) {
                                // Manejar los cambios en el campo de series aquí
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          ListTile(
                            title: TextField(
                              decoration: InputDecoration(
                                  labelText: 'Repeticiones'),
                              controller: _repeticionesControllers[index],
                              onChanged: (value) {
                                // Manejar los cambios en el campo de repeticiones aquí
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _eliminarEjercicio(widget.rutinaId, index);
                            },
                          ),
                        ]
                            : [],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _agregarEjercicio,
            ),
            IconButton(
              icon: Icon(Icons.create),
              onPressed: _crearEjercicio,
            ),
          ],
        ),
      ),
    );
  }
}
