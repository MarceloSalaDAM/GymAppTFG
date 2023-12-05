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
  late PageController _pageController;
  List<Map<String, dynamic>> ejerciciosTemporales = [];

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
  int selectedDias = 3;
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

  void agregarEjercicio(
    String pesoText,
    String repeticionesText,
    String seriesText,
    TextEditingController pesoController,
    TextEditingController repeticionesController,
    TextEditingController seriesController,
    Ejercicios ejercicio,
  ) {
    // Verifica que todos los campos estén llenos y contengan valores numéricos
    if (pesoText.isNotEmpty &&
        repeticionesText.isNotEmpty &&
        seriesText.isNotEmpty) {
      // Intenta convertir los valores a números
      try {
        int peso = int.parse(pesoText);
        int repeticiones = int.parse(repeticionesText);
        int series = int.parse(seriesText);

        // Obtiene el nombre del ejercicio desde el filtro anterior
        String nombreEjercicio = ejercicio.nombre ?? 'Nombre no disponible';

        // Crea un mapa con los datos del ejercicio
        Map<String, dynamic> datosEjercicio = {
          'nombre': nombreEjercicio,
          'peso': peso,
          'repeticiones': repeticiones,
          'series': series,
        };

        // Agrega el ejercicio a la lista temporal
        ejerciciosTemporales.add(datosEjercicio);
        print('Ejercicios Temporales: $ejerciciosTemporales');

        // Limpia los controladores después de agregar el ejercicio
        pesoController.clear();
        repeticionesController.clear();
        seriesController.clear();
      } catch (e) {
        // Maneja el caso en que los valores no sean números válidos
        print(
            'Por favor, ingresa valores numéricos válidos para peso, repeticiones y series.');
      }
    } else {
      // Muestra un mensaje de error o realiza alguna acción cuando los campos no están llenos
      print('Por favor, completa todos los campos.');
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
                                                } else {
                                                  selectedDiasSemana
                                                      .remove(dia);
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
                              // Variables para almacenar los valores editables
                              TextEditingController pesoController =
                                  TextEditingController();
                              TextEditingController repeticionesController =
                                  TextEditingController();
                              TextEditingController seriesController =
                                  TextEditingController();
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

                                child: ExpansionTile(
                                  title: Text(
                                    ejercicio.nombre ?? 'Nombre no disponible',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
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
                                          TextFormField(
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            controller: pesoController,
                                            decoration: const InputDecoration(
                                              labelText: 'Peso (kg)',
                                            ),
                                          ),
                                          TextFormField(
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            controller: repeticionesController,
                                            decoration: const InputDecoration(
                                              labelText: 'Repeticiones',
                                            ),
                                          ),

                                          TextFormField(
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            controller: seriesController,
                                            decoration: const InputDecoration(
                                              labelText: 'Series',
                                            ),
                                          ),

                                          const SizedBox(height: 8.0),
                                          // Espaciado entre campos editables y botón
                                          ElevatedButton(
                                            onPressed: () {
                                              agregarEjercicio(
                                                pesoController.text,
                                                repeticionesController.text,
                                                seriesController.text,
                                                pesoController,
                                                repeticionesController,
                                                seriesController,
                                                ejercicio,
                                              );
                                            },
                                            child: const Text('Añadir'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            ExpansionTile(
                              title: const Text(
                                'Crear Nuevo Ejercicio',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_drop_down,
                                  color: Color(0XFF0f7991)),
                              children: [
                                // Campos editables para el nuevo ejercicio
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        // Campo para el nombre del nuevo ejercicio
                                        decoration: const InputDecoration(
                                            labelText: 'Nombre del Ejercicio'),
                                      ),
                                      TextFormField(
                                        // Campo para la descripción del nuevo ejercicio
                                        decoration: const InputDecoration(
                                            labelText:
                                                'Descripción del Ejercicio'),
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
                                      // Espaciado entre campos editables y botón
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: const Text('Añadir'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  // Navegar a la siguiente página
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                icon: const Icon(
                  Icons.arrow_right_alt,
                  size: 30,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  // Lógica para guardar todas las rutinas
                  // Puedes utilizar la lista ejerciciosTemporales
                  // y guardarla en la subcolección 'rutinas' del usuario en Firebase
                  guardarRutinasEnFirebase(ejerciciosTemporales);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void guardarRutinasEnFirebase(
      List<Map<String, dynamic>> ejerciciosTemporales) async {
    try {
      // Obtener el ID del usuario actual
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Crear una referencia a la colección 'rutinas' del usuario en Firestore
      CollectionReference rutinasCollection = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('rutinas');

      // Crear un mapa que contenga los datos de la rutina
      Map<String, dynamic> datosRutina = {
        'dias': {},
      };

      // Añadir los grupos musculares seleccionados para cada día
      for (var dia in selectedDiasSemana) {
        // Filtrar los grupos musculares seleccionados para el día actual
        var gruposSeleccionados = selectedGroupsMap[dia]?.toList() ?? [];

        // Convertir la lista de grupos a un string separado por comas
        String gruposString = gruposSeleccionados.join(',');

        // Filtrar los ejercicios seleccionados para los grupos y día actual
        var ejerciciosSeleccionados = ejerciciosTemporales
            .where((ejercicio) =>
                gruposSeleccionados.contains(ejercicio['grupo']) &&
                selectedDiasSemana.contains(dia))
            .map((ejercicio) => {
                  'nombre': ejercicio['nombre'],
                  'peso': ejercicio['peso'],
                  'repeticiones': ejercicio['repeticiones'],
                  'series': ejercicio['series'],
                })
            .toList();

        // Obtener el array de ejercicios básicos para el grupo actual
        var ejerciciosBasicos = ejerciciosTemporales;

        // Añadir el grupo y el array de ejercicios al mapa del día
        datosRutina['dias'][dia] = {
          'grupo': gruposString,
          'ejercicios': [...ejerciciosSeleccionados, ...ejerciciosBasicos],
        };
      }

      // Añadir la rutina a la colección 'rutinas'
      await rutinasCollection.add(datosRutina);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutina guardada exitosamente en Firebase.'),
        ),
      );
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante el proceso
      print('Error al guardar la rutina en Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hubo un error al guardar la rutina en Firebase.'),
        ),
      );
    }
  }

  List<Map<String, dynamic>> obtenerEjerciciosBasicos() {
    // Definir ejercicios básicos, puedes personalizar esta lista según tus necesidades
    return [
      {'nombre': 'Flexiones', 'peso': 0, 'repeticiones': 15, 'series': 3},
      {'nombre': 'Sentadillas', 'peso': 0, 'repeticiones': 12, 'series': 3},
      // Agregar más ejercicios básicos según sea necesario
    ];
  }
}
