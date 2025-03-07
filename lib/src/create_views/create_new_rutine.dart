import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../custom/alert_dialogs.dart';
import '../firebase_objects/ejercicios_firebase.dart';
import '../list_views/exercise_list_view.dart';

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

  List<String> obtenerGrupos(List<Ejercicios> ejercicios) {
    Set<String> grupos = <String>{};
    for (var ejercicio in ejercicios) {
      if (ejercicio.grupo != null) {
        grupos.add(ejercicio.grupo!);
      }
    }
    return grupos.toList()..sort();
  }

  void guardarRutinaEnFirebase(String nombre, String descripcion) async {
    try {
      // Obtener el ID del usuario actual
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Crear una referencia a la colección 'rutinas' del usuario en Firestore
      CollectionReference rutinasCollection = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('rutinas');

      Map<String, dynamic> datosPrimeraParteRutina = {
        'dias': {},
      };

// Añadir los grupos musculares seleccionados para cada día
      for (var dia in selectedDiasSemana) {
        // Obtener el grupo muscular seleccionado para este día
        String? grupoSeleccionado = selectedGroupsMap[dia]?.isNotEmpty == true
            ? selectedGroupsMap[dia]?.first
            : null;

        // Añadir el grupo muscular al mapa del día
        datosPrimeraParteRutina['dias'][dia] = {
          'grupo': grupoSeleccionado,
          'ejercicios': [],
        };

        // Añadir los valores seleccionados para cada día y ejercicio
        valoresSeleccionados[dia]?.forEach((ejercicio, valores) {
          datosPrimeraParteRutina['dias'][dia]['ejercicios'].add({
            'nombre': ejercicio,
            'peso': valores['peso'],
            'repeticiones': valores['repeticiones'],
            'series': valores['series'],
          });
        });
      }

      // Agregar nombre y descripción directamente al mapa
      datosPrimeraParteRutina['nombre'] = nombre;
      datosPrimeraParteRutina['descripcion'] = descripcion;

      // Agregar los datos a Firestore
      rutinasCollection.add(datosPrimeraParteRutina);

      print(
          "DATOS RECOPLIADOS--------->>>$datosPrimeraParteRutina");

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RUTINA GUARDADA CON ÉXITO'),
        ),
      );
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante el proceso
      print('Error al guardar la rutina en Firebase: $e');

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

// Función para verificar si un ejercicio está seleccionado para un día específico
  bool isSelectedExerciseForDay(Ejercicios ejercicio, String dia) {
    final ejercicioNombre = ejercicio.nombre; // Obtener el nombre del ejercicio
    return selectedGroupsMap[dia]?.contains(ejercicioNombre) ?? false;
  }

// Función para alternar la selección de un ejercicio para un día específico
  void toggleSelectedExerciseForDay(Ejercicios ejercicio, String dia) {
    setState(() {
      final ejercicioNombre =
          ejercicio.nombre; // Obtener el nombre del ejercicio
      if (isSelectedExerciseForDay(ejercicio, dia)) {
        selectedGroupsMap[dia]?.remove(ejercicioNombre);
      } else {
        selectedGroupsMap[dia]?.add(ejercicioNombre);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        automaticallyImplyLeading: false,
        title: const Text(
          'CREAR RUTINA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Mostrar el icono solo en la Page 1 (currentPageIndex == 1)
        leading: currentPageIndex == 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  // Llama al método para mostrar el AlertDialog específico
                  await AlertDialogManager.showExitConfirmation(context);
                },
              )
            : null,
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
                          SizedBox(
                            height: MediaQuery.of(context).size.height > 800
                                ? 340
                                : 175,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mantén pulsado sobre el ejercicio para ver más información',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: Container(
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
                                      child: InkWell(
                                        onLongPress: () {
                                          // Obtén el nombre del ejercicio sobre el cual se ha realizado el toque largo
                                          String ejercicioSeleccionado =
                                              ejercicio.nombre;
                                          // Filtra la lista de ejercicios para encontrar el ejercicio seleccionado
                                          var ejercicioElegido =
                                              widget.ejercicios.firstWhere(
                                            (ejercicio) =>
                                                ejercicio.nombre ==
                                                ejercicioSeleccionado,
                                          ); // Reemplaza esto con la lógica real
                                          // Navega a la pantalla de ExerciseListScreen con el ejercicio seleccionado
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ExerciseListScreen(
                                                ejercicios: [
                                                  ejercicioElegido
                                                ],
                                              ),
                                            ),
                                          );
                                                                                },
                                        child: ExpansionTile(
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    value:
                                                        isSelectedExerciseForDay(
                                                            ejercicio, dia),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        toggleSelectedExerciseForDay(
                                                            ejercicio, dia);
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Flexible(
                                                    child: Text(
                                                      ejercicio.nombre,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_drop_down,
                                            color: Color(0XFF0f7991),
                                          ),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.0),
                                                    child: Text('Peso (kg)'),
                                                  ),
                                                  TextFormField(
                                                    initialValue:
                                                        (ejercicioValues[
                                                                    'peso'] ??
                                                                0.0)
                                                            .toString(),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        ejercicioValues[
                                                                'peso'] =
                                                            double.tryParse(
                                                                    value) ??
                                                                0.0;
                                                        actualizarValores(
                                                            dia,
                                                            ejercicio.nombre,
                                                            ejercicioValues);
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Peso (kg)',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8.0),
                                                  // DropdownButton para Repeticiones
                                                  DropdownButtonFormField<int>(
                                                    value: ejercicioValues[
                                                        'repeticiones'],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        ejercicioValues[
                                                                'repeticiones'] =
                                                            value;
                                                        actualizarValores(
                                                            dia,
                                                            ejercicio.nombre,
                                                            ejercicioValues);
                                                      });
                                                    },
                                                    items: List.generate(
                                                        30,
                                                        (index) =>
                                                            index + 1).map<
                                                        DropdownMenuItem<
                                                            int>>((int value) {
                                                      return DropdownMenuItem<
                                                          int>(
                                                        value: value,
                                                        child: Text(
                                                            value.toString()),
                                                      );
                                                    }).toList(),
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Repeticiones',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                  // DropdownButton para Series
                                                  DropdownButtonFormField<int>(
                                                    value: ejercicioValues[
                                                        'series'],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        ejercicioValues[
                                                            'series'] = value;
                                                        actualizarValores(
                                                            dia,
                                                            ejercicio.nombre,
                                                            ejercicioValues);
                                                      });
                                                    },
                                                    items: List.generate(
                                                        10,
                                                        (index) =>
                                                            index + 1).map<
                                                        DropdownMenuItem<
                                                            int>>((int value) {
                                                      return DropdownMenuItem<
                                                          int>(
                                                        value: value,
                                                        child: Text(
                                                            value.toString()),
                                                      );
                                                    }).toList(),
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'Series',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8.0),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
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
                ElevatedButton.icon(
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
                    color: Colors.white,
                  ),
                  label: const Text(
                    "CONTINUAR",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF0f7991),
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
                ElevatedButton.icon(
                  onPressed: () {
                    mostrarDialogoGuardarRutina(context);
                  },
                  icon: const Icon(
                    Icons.save_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "GUARDAR RUTINA",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF0f7991),
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

  void mostrarDialogoGuardarRutina(BuildContext context) {
    String nombre = '';
    String descripcion = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Guardar Rutina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    nombre = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la rutina',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    descripcion = value;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Descripción de la rutina',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Ajuste del padding
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                guardarRutinaEnFirebase(nombre, descripcion);
                Navigator.popUntil(context, ModalRoute.withName('/Main'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
          ],
        );
      },
    );
  }

}
