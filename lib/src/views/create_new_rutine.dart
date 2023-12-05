import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../firebase_objects/ejercicios_firebase.dart';

class CrearRutinaView extends StatefulWidget {
  final List<Ejercicios> ejercicios;

  const CrearRutinaView({Key? key, required this.ejercicios}) : super(key: key);

  @override
  _CrearRutinaViewState createState() => _CrearRutinaViewState();
}

class _CrearRutinaViewState extends State<CrearRutinaView> {
  late PageController _pageController;
  Map<String, Set<String>> selectedGroupsMap = {
    "LUNES": Set<String>(),
    "MARTES": Set<String>(),
    "MIÉRCOLES": Set<String>(),
    "JUEVES": Set<String>(),
    "VIERNES": Set<String>(),
    "SÁBADO": Set<String>(),
    "DOMINGO": Set<String>(),
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
    Set<String> grupos = Set<String>();
    for (var ejercicio in ejercicios) {
      if (ejercicio.grupo != null) {
        grupos.add(ejercicio.grupo!);
      }
    }
    return grupos.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    print('Ejercicios en CrearRutinaView: ${widget.ejercicios}');
    List<String> grupos = obtenerGrupos(widget.ejercicios);
    print('Grupos disponibles: $grupos');
    selectedGroup = grupos.isNotEmpty ? grupos.first : '';
    print('Selected Group: $selectedGroup');

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
        title: const Text(
          'CREAR RUTINA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0XFF0f7991),
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
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
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
                    key: Key('ContainerKey'),
                    color: Colors.blue,
                    child: ListView.builder(
                      key: const Key('ListViewKey'),
                      itemCount: selectedDiasSemana.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dia = selectedDiasSemana[index];
                        final selectedGroups = selectedGroupsMap[dia] ?? <String>[]; // Asegúrate de que selectedGroups no sea nulo

                        return Column(
                          children: [
                            ExpansionTile(
                              title: Text(
                                dia,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_drop_down, color: Color(0XFF0f7991)),
                              children: <Widget>[
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 0.0,
                                  children: selectedGroups.expand((grupo) {
                                    // Filtra la lista de ejercicios para el grupo muscular seleccionado
                                    final ejerciciosFiltrados = widget.ejercicios
                                        .where((ejercicio) => ejercicio.grupo == grupo)
                                        .toList();

                                    return ejerciciosFiltrados.map((ejercicio) {
                                      return ListTile(
                                        title: Text(ejercicio.nombre ?? 'Nombre no disponible',),
                                        // Puedes agregar más propiedades de ListTile según sea necesario
                                      );
                                    });
                                  }).toList(),
                                ),
                              ],
                            ),
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
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                icon: Icon(
                  Icons.arrow_right_alt,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
