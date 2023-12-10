import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../custom/alert_dialogs.dart';
import '../firebase_objects/ejercicios_firebase.dart';

class CrearRutinaView extends StatefulWidget {
  final List<Ejercicios> ejercicios;

  const CrearRutinaView({Key? key, required this.ejercicios}) : super(key: key);

  @override
  _CrearRutinaViewState createState() => _CrearRutinaViewState();
}

class _CrearRutinaViewState extends State<CrearRutinaView> {
  int currentPageIndex = 0;
  double selectedWeight = 0.0;
  double minWeight = 0.0;
  double maxWeight = 200.0;
  double weightInterval = 1.25;
  Map<String, Map<String, Map<String, dynamic>>> valoresSeleccionados = {};
  late PageController _pageController;
  String selectedDay = " ";
  late String selectedGroup;
  List<Ejercicios> selectedExercises = [];
  Map<String, Set<String>> selectedGroupsMap = {
    "LUNES": <String>{},
    "MARTES": <String>{},
    "MIÉRCOLES": <String>{},
    "JUEVES": <String>{},
    "VIERNES": <String>{},
    "SÁBADO": <String>{},
    "DOMINGO": <String>{},
  };
  List<String> selectedDiasSemana = [
    "LUNES",
    "MARTES",
    "MIÉRCOLES",
    "JUEVES",
    "VIERNES",
    "SÁBADO",
    "DOMINGO"
  ];

  // Función para verificar si un ejercicio está seleccionado
  bool isSelectedExercise(Ejercicios ejercicio) {
    return selectedExercises.contains(ejercicio);
  }

  // Función para alternar la selección de un ejercicio
  void toggleSelectedExercise(Ejercicios ejercicio) {
    setState(() {
      if (isSelectedExercise(ejercicio)) {
        selectedExercises.remove(ejercicio);
      } else {
        selectedExercises.add(ejercicio);
      }
    });
  }

  List<String> obtenerGrupos(List<Ejercicios> ejercicios) {
    Set<String> grupos = <String>{};
    for (var ejercicio in ejercicios) {
      if (ejercicio.grupo != null) {
        grupos.add(ejercicio.grupo!);
      }
    }
    return grupos.toList()..sort();
  }

  void guardarRutinaEnFirebase() async {
    try {
      // Obtener el ID del usuario actual
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Crear una referencia a la colección 'rutinas' del usuario en Firestore
      CollectionReference rutinasCollection = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('rutinas');

      // Crear un mapa que contiene los datos de la segunda parte de la rutina
      Map<String, dynamic> datosSegundaParteRutina = {};

      // Añadir los valores seleccionados para cada día y ejercicio
      valoresSeleccionados.forEach((dia, ejercicios) {
        datosSegundaParteRutina[dia] = [];
        ejercicios.forEach((ejercicio, valores) {
          datosSegundaParteRutina[dia].add({
            'nombre': ejercicio,
            'peso': valores['peso'],
            'repeticiones': valores['repeticiones'],
            'series': valores['series'],
          });
        });
      });

      rutinasCollection.add(datosSegundaParteRutina);

      print(
          "DATOS RECOPLIADOS--------->>>" + datosSegundaParteRutina.toString());

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RUTINA GUARDADA CON ÉXITO'),
        ),
      );
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante el proceso
      print('Error al guardar la segunda parte de la rutina en Firebase: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ERROR AL GUARDAR LA RUTINA',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    List<String> grupos = obtenerGrupos(widget.ejercicios);
    selectedGroup = grupos.isNotEmpty ? grupos.first : '';
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        currentPageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            // Llama al método para mostrar el AlertDialog específico
            await AlertDialogManager.showExitConfirmation(context);
          },
        ),
        title: const Text(
          'CREAR RUTINA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Días de la semana',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                spacing: 30.0,
                                runSpacing: 2.0,
                                children: [
                                  for (var dia in [
                                    "LUNES",
                                    "MARTES",
                                    "MIÉRCOLES",
                                    "JUEVES",
                                    "VIERNES",
                                    "SÁBADO",
                                    "DOMINGO",
                                  ])
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          activeColor: const Color(0XFF0f7991),
                                          value:
                                              selectedDiasSemana.contains(dia),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value != null) {
                                                if (value) {
                                                  selectedDiasSemana.add(dia);
                                                  selectedDay =
                                                      dia; // Update the selected day
                                                } else {
                                                  selectedDiasSemana
                                                      .remove(dia);
                                                  selectedDay =
                                                      " "; // Reset the selected day if none is selected
                                                }
                                              }
                                            });
                                          },
                                        ),
                                        Text(
                                          dia,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Grupo muscular por día',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lista de días seleccionados
                          Container(
                            height: MediaQuery.of(context).size.height > 800
                                ? 340
                                : 220,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: selectedDiasSemana.length,
                              itemBuilder: (BuildContext context, int index) {
                                final dia = selectedDiasSemana[index];
                                return Card(
                                  // Agrega el widget Card como contenedor
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  // Espacio alrededor de cada Card
                                  child: ExpansionTile(
                                    title: Text(
                                      dia,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_drop_down,
                                        color: Color(0XFF0f7991)),
                                    children: <Widget>[
                                      Wrap(
                                        spacing: 8.0,
                                        runSpacing: 0.0,
                                        children:
                                            obtenerGrupos(widget.ejercicios)
                                                .map((grupo) {
                                          bool isSelected =
                                              selectedGroupsMap[dia]!
                                                  .contains(grupo);

                                          return ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                if (isSelected) {
                                                  selectedGroupsMap[dia]!
                                                      .remove(grupo);
                                                } else {
                                                  selectedGroupsMap[dia]!
                                                      .add(grupo);
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isSelected
                                                  ? const Color(0XFF0f7991)
                                                  : Colors.grey,
                                              minimumSize: const Size(0, 0),
                                            ),
                                            child: Text(
                                              grupo,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    key: const Key('ContainerKey'),
                    child: ListView.builder(
                      key: const Key('ListViewKey'),
                      itemCount: selectedDiasSemana.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dia = selectedDiasSemana[index];
                        final selectedExercises = widget.ejercicios
                            .where((ejercicio) =>
                                selectedGroupsMap[dia]
                                    ?.contains(ejercicio.grupo) ??
                                false)
                            .toList();

                        return Column(
                          children: [
                            Container(
                              color: Colors.black,
                              width: double.infinity,
                              height: 40,
                              alignment: Alignment.center,
                              child: Text(
                                dia,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Lista de ejercicios asociados al día
                            ...selectedExercises.map((ejercicio) {
                              Map<String, dynamic> ejercicioValues =
                                  valoresSeleccionados[dia]
                                          ?[ejercicio.nombre] ??
                                      {};
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ExpansionTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value:
                                                isSelectedExercise(ejercicio),
                                            onChanged: (value) {
                                              setState(() {
                                                toggleSelectedExercise(
                                                    ejercicio);
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 8.0),
                                          Flexible(
                                            child: Text(
                                              ejercicio.nombre,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_drop_down,
                                      color: Color(0XFF0f7991)),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(
                                              'Peso (kg)',
                                            ),
                                          ),
                                          Slider(
                                            value:
                                                ejercicioValues['peso'] ?? 0.0,
                                            min: minWeight,
                                            max: maxWeight,
                                            divisions:
                                                (maxWeight - minWeight) ~/
                                                    weightInterval,
                                            onChanged: (value) {
                                              setState(() {
                                                ejercicioValues['peso'] =
                                                    (value / weightInterval)
                                                            .round() *
                                                        weightInterval;
                                                actualizarValores(
                                                    dia,
                                                    ejercicio.nombre,
                                                    ejercicioValues);
                                              });
                                            },
                                            label:
                                                (ejercicioValues['peso'] ?? 0.0)
                                                    .toString(),
                                          ),
                                          const SizedBox(height: 2.0),
                                          // DropdownButton para Repeticiones
                                          DropdownButtonFormField<int>(
                                            value:
                                                ejercicioValues['repeticiones'],
                                            onChanged: (value) {
                                              setState(() {
                                                ejercicioValues[
                                                    'repeticiones'] = value;
                                                actualizarValores(
                                                    dia,
                                                    ejercicio.nombre,
                                                    ejercicioValues);
                                              });
                                            },
                                            items: List.generate(
                                                    30, (index) => index + 1)
                                                .map<DropdownMenuItem<int>>(
                                                    (int value) {
                                              return DropdownMenuItem<int>(
                                                value: value,
                                                child: Text(value.toString()),
                                              );
                                            }).toList(),
                                            decoration: const InputDecoration(
                                              labelText: 'Repeticiones',
                                            ),
                                          ),
                                          // DropdownButton para Series
                                          DropdownButtonFormField<int>(
                                            value: ejercicioValues['series'],
                                            onChanged: (value) {
                                              setState(() {
                                                ejercicioValues['series'] =
                                                    value;
                                                actualizarValores(
                                                    dia,
                                                    ejercicio.nombre,
                                                    ejercicioValues);
                                              });
                                            },
                                            items: List.generate(
                                                    10, (index) => index + 1)
                                                .map<DropdownMenuItem<int>>(
                                                    (int value) {
                                              return DropdownMenuItem<int>(
                                                value: value,
                                                child: Text(value.toString()),
                                              );
                                            }).toList(),
                                            decoration: const InputDecoration(
                                              labelText: 'Series',
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón para avanzar a la Page 2 (visible en Page 1)
              if (currentPageIndex == 0)
                IconButton(
                  onPressed: () {
                    // Navegar a la Page 2
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_circle_right_rounded,
                    size: 30,
                  ),
                ),

              // Botón para volver a la Page 1 (visible en Page 2)
              if (currentPageIndex == 1)
                IconButton(
                  onPressed: () {
                    // Navegar a la Page 1
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    size: 30,
                  ),
                ),

              // Botón para guardar (visible en Page 2)
              if (currentPageIndex == 1)
                IconButton(
                  onPressed: () async {
                    guardarRutinaEnFirebase();
                    Navigator.popUntil(context, ModalRoute.withName('/Main'));
                  },
                  icon: const Icon(
                    Icons.save_outlined,
                    size: 30,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void actualizarValores(
      String dia, String ejercicio, Map<String, dynamic> valores) {
    {
      setState(() {
        if (!valoresSeleccionados.containsKey(dia)) {
          valoresSeleccionados[dia] = {};
        }
        if (!valoresSeleccionados[dia]!.containsKey(ejercicio)) {
          valoresSeleccionados[dia]![ejercicio] = {};
        }
        valoresSeleccionados[dia]![ejercicio]!['nombre'] = ejercicio;
        valoresSeleccionados[dia]![ejercicio]!['peso'] = valores['peso'];
        valoresSeleccionados[dia]![ejercicio]!['repeticiones'] =
            valores['repeticiones'];
        valoresSeleccionados[dia]![ejercicio]!['series'] = valores['series'];
      });
    }
  }
}
