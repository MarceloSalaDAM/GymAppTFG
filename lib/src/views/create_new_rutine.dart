import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../custom/alert_dialogs.dart';
import '../firebase_objects/ejercicios_firebase.dart';
import 'exercise_list_view.dart';

class CrearRutinaView extends StatefulWidget {
  final List<Ejercicios> ejercicios;

  const CrearRutinaView({Key? key, required this.ejercicios}) : super(key: key);

  @override
  _CrearRutinaViewState createState() => _CrearRutinaViewState();
}

class _CrearRutinaViewState extends State<CrearRutinaView> {
  double selectedWeight = 0.0;
  double minWeight = 0.0;
  double maxWeight = 200.0;
  double weightInterval = 1.25;
  TextEditingController repeticionesController = TextEditingController();
  TextEditingController seriesController = TextEditingController();
  late PageController _pageController;
  late String idRutina;

  String selectedDay =
      " "; // Set a default day, you can change it based on your needs

  // Mantén los valores actuales de los controladores en el estado del widget
  late String pesoValue;
  late String repeticionesValue;
  late String seriesValue;

  Map<String, Set<String>> selectedGroupsMap = {
    "LUNES": <String>{},
    "MARTES": <String>{},
    "MIÉRCOLES": <String>{},
    "JUEVES": <String>{},
    "VIERNES": <String>{},
    "SÁBADO": <String>{},
    "DOMINGO": <String>{},
  };
  late String selectedGroup;
  List<String> selectedDiasSemana = [
    "LUNES",
    "MARTES",
    "MIÉRCOLES",
    "JUEVES",
    "VIERNES",
    "SÁBADO",
    "DOMINGO"
  ];

  List<Ejercicios> selectedExercises = [];

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

  void guardarPrimeraParteRutinaEnFirebase() async {
    try {
      // Obtener el ID del usuario actual
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Crear una referencia a la colección 'rutinas' del usuario en Firestore
      CollectionReference rutinasCollection = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('rutinas');

      // Crear un mapa que contenga los datos de la primera parte de la rutina
      Map<String, dynamic> datosPrimeraParteRutina = {
        'dias': {},
      };

      // Añadir los grupos musculares seleccionados para cada día
      for (var dia in selectedDiasSemana) {
        // Filtrar los grupos musculares seleccionados para el día actual
        var gruposSeleccionados = selectedGroupsMap[dia]?.toList() ?? [];

        // Convertir la lista de grupos a un string separado por comas
        String gruposString = gruposSeleccionados.join(',');

        // Añadir el grupo al mapa del día
        datosPrimeraParteRutina['dias'][dia] = {
          'grupo': gruposString,
        };
      }
      // Añadir la primera parte de la rutina a la colección 'rutinas'
      var result = await rutinasCollection.add(datosPrimeraParteRutina);
      print("DATOS PRIMERA PARTE RUTINA----------->" +
          datosPrimeraParteRutina.toString());

      // Almacenar el ID de la rutina recién creada
      idRutina = result.id;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primera parte de la rutina guardada en Firebase.'),
        ),
      );
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante el proceso
      print('Error al guardar la primera parte de la rutina en Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Hubo un error al guardar la primera parte de la rutina en Firebase.'),
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
        padding: const EdgeInsets.all(25.0), // Añade padding aquí
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Página 1: Contenido actual
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
                            // Ajusta la elevación según tus preferencias
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              // Opcional: Añade esquinas redondeadas al borde de la tarjeta
                              side: const BorderSide(
                                  color: Colors
                                      .grey), // Opcional: Añade un borde alrededor de la tarjeta
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              // Ajusta el espaciado interno de la tarjeta según tus preferencias
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
                      // Nuevo Column para la lista de días
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
                  // Página 2: Nuevo contenido (puedes personalizar según tus necesidades)
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
                              return GestureDetector(
                                // Puedes ajustar la duración según tus preferencias
                                onLongPress: () {
                                  // Obtén el nombre del ejercicio sobre el cual se ha realizado el toque largo
                                  String ejercicioSeleccionado = ejercicio
                                          .nombre ??
                                      'Nombre no disponible'; // Reemplaza esto con la lógica real

                                  // Filtra la lista de ejercicios para encontrar el ejercicio seleccionado
                                  var ejercicioElegido =
                                      widget.ejercicios.firstWhere(
                                    (ejercicio) =>
                                        ejercicio.nombre ==
                                        ejercicioSeleccionado,
                                  );

                                  if (ejercicioElegido != null) {
                                    // Navega a la pantalla de ExerciseListScreen con el ejercicio seleccionado
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ExerciseListScreen(
                                          ejercicios: [ejercicioElegido],
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Manejar el caso en que no se encuentre el ejercicio
                                    print(
                                        'No se encontró el ejercicio seleccionado: $ejercicioSeleccionado');
                                  }
                                },

                                child: Padding(
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
                                            // Espaciado entre el checkbox y el texto
                                            Flexible(
                                              // Usa Flexible o Expanded aquí
                                              child: Text(
                                                ejercicio.nombre ??
                                                    'Nombre no disponible',
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
                                      // Campos editables
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(
                                                'Peso (kg)',
                                              ),
                                            ),
                                            Slider(
                                              value: selectedWeight,
                                              min: minWeight,
                                              max: maxWeight,
                                              divisions:
                                                  (maxWeight - minWeight) ~/
                                                          weightInterval,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedWeight =
                                                      (value / weightInterval)
                                                              .round() *
                                                          weightInterval;
                                                });
                                              },
                                              label: selectedWeight.toString(),
                                            ),
                                            const SizedBox(height: 2.0),
// DropdownButton para Repeticiones
                                            DropdownButtonFormField<int>(
                                              value: repeticionesController
                                                      .text.isNotEmpty
                                                  ? int.parse(
                                                      repeticionesController
                                                          .text)
                                                  : null,
                                              onChanged: (value) {
                                                setState(() {
                                                  repeticionesController.text =
                                                      value.toString();
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
                                            DropdownButtonFormField<int>(
                                              value: seriesController
                                                      .text.isNotEmpty
                                                  ? int.parse(
                                                      seriesController.text)
                                                  : null,
                                              onChanged: (value) {
                                                setState(() {
                                                  seriesController.text =
                                                      value.toString();
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
                                ),
                              );
                            }).toList(),
                            /* Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ExpansionTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        const SizedBox(width: 8.0), // Espaciado entre el checkbox y el texto
                                        const Flexible( // Usa Flexible o Expanded aquí
                                          child: Text(
                                            'Crear Nuevo Ejercicio',
                                            style: TextStyle(
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
                                trailing: const Icon(Icons.arrow_drop_down, color: Color(0XFF0f7991)),
                                children: [
                                  // Campos editables para el nuevo ejercicio
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          // Campo para el nombre del nuevo ejercicio
                                          decoration: const InputDecoration(
                                            labelText: 'Nombre del Ejercicio',
                                          ),
                                        ),
                                        TextFormField(
                                          // Campo para la descripción del nuevo ejercicio
                                          decoration: const InputDecoration(
                                            labelText: 'Descripción del Ejercicio',
                                          ),
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.phone,
                                          decoration: const InputDecoration(
                                            labelText: 'Peso (kg)',
                                          ),
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.phone,
                                          decoration: const InputDecoration(
                                            labelText: 'Repeticiones',
                                          ),
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.phone,
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
                            ),*/

                            const SizedBox(height: 8.0),
                            // Espaciado entre ExpansionTiles
                          ],
                        );
                      },
                    ),
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
              IconButton(
                onPressed: () {
                  // Lógica para guardar la primera parte de la rutina
                  guardarPrimeraParteRutinaEnFirebase();

                  // Navegar a la Page 2
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                icon: const Icon(
                  Icons.save,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: () async {
                  //await guardarSegundaParteRutinaEnFirebase();
                  // Aquí puedes realizar cualquier otra acción después de guardar en Firebase
                },
                icon: const Icon(
                  Icons.golf_course,
                  size: 30,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
