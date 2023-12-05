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
        padding: const EdgeInsets.all(20.0), // Añade padding aquí
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: const Text(
                "CONFIGURAR NUEVA RUTINA",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  // Página 1: Contenido actual
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
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
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
                                  value: selectedDiasSemana.contains(dia),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value != null) {
                                        if (value) {
                                          selectedDiasSemana.add(dia);
                                        } else {
                                          selectedDiasSemana.remove(dia);
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
                      const SizedBox(height: 20),
                      const Text(
                        'Grupo muscular por día',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Nuevo Column para la lista de días
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lista de días seleccionados
                          Container(
                            height: 250,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: selectedDiasSemana.length,
                              itemBuilder: (BuildContext context, int index) {
                                final dia = selectedDiasSemana[index];
                                return ExpansionTile(
                                  title: Text(
                                    dia,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  trailing: Icon(Icons.arrow_drop_down,
                                      color: const Color(0XFF0f7991)),
                                  children: <Widget>[
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 0.0,
                                      children: obtenerGrupos(widget.ejercicios)
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
                    // Puedes cambiar el color o utilizar otro widget
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedGroup,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.black,
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          dropdownColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              selectedGroup = value!;
                            });
                          },
                          items: obtenerGrupos(widget.ejercicios).map((grupo) {
                            return DropdownMenuItem<String>(
                              value: grupo,
                              child: Text(
                                grupo,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ),
                        Expanded(
                          child: ListView.builder(
                            key: const Key('ListViewKey'),
                            itemCount: widget.ejercicios
                                .where((ejercicio) =>
                                    ejercicio.grupo == selectedGroup)
                                .length,
                            itemBuilder: (BuildContext context, int index) {
                              final ejercicio = widget.ejercicios
                                  .where((ejercicio) =>
                                      ejercicio.grupo == selectedGroup)
                                  .toList()[index];

                              return ListTile(
                                title: Text(
                                    ejercicio.nombre ?? 'Nombre no disponible'),
                                onTap: () {
                                  // Agrega aquí la lógica para manejar el tap en el elemento
                                },
                              );
                            },
                          ),
                        ),
                        // Agrega aquí los elementos del nuevo contenido
                      ],
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
                  // Navegar a la siguiente página
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                icon: Icon(Icons.arrow_right_alt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
