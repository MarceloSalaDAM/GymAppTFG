import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_objects/rutinas_firebase.dart';

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
    } catch (error) {
      // Manejar cualquier error que pueda ocurrir durante la actualización en Firebase
      print('Error al guardar cambios en Firebase: $error');
      // También puedes mostrar un SnackBar indicando el error al usuario si lo prefieres
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
    } catch (e) {
      // Maneja el error según tus necesidades
      print("Error al cargar la rutina original: $e");
    }
  }

  void _resetData() {
    setState(() {
      // Reinicia el estado para mostrar los datos iniciales
      editModeByDay = {};
      editingExercisesByDay = {};
    });

    // Cargar de nuevo los datos originales de la rutina
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
            ],
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
    print('Valores iniciales al entrar en la vista para el día $dia:');

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
                          // Encuentra el ejercicio actual en la lista y actualiza solo ese ejercicio
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
                          print("Cambiando repeticiones: $value");
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
                          print("Cambiando peso: $value");
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
