import 'package:flutter/material.dart';
import '../firebase_objects/ejercicios_firebase.dart';

class CrearRutinaView extends StatefulWidget {
  final List<Ejercicios> ejercicios;

  const CrearRutinaView({Key? key, required this.ejercicios}) : super(key: key);

  @override
  _CrearRutinaViewState createState() => _CrearRutinaViewState();
}

class _CrearRutinaViewState extends State<CrearRutinaView> {
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
  }

  @override
  Widget build(BuildContext context) {
    widget.ejercicios
        .sort((a, b) => (a.nombre ?? '').compareTo(b.nombre ?? ''));

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
        padding: const EdgeInsets.all(30.0),
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
            const SizedBox(height: 20),
            const Text(
              'Días a la semana:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            DropdownButtonFormField<int>(
              value: selectedDias,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Colors.black,
              onChanged: (value) {
                setState(() {
                  selectedDias = value!;
                });
              },
              items:
                  [1, 2, 3, 4, 5, 6, 7].map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
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
                  // Ajusta el espacio horizontal entre los elementos
                  runSpacing: 4.0,
                  // Ajusta el espacio vertical entre los elementos
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
                            style: TextStyle(
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
              ],
            ),
            const SizedBox(height: 25),
            DropdownButtonFormField<String>(
              value: selectedGroup,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.ejercicios
                    .where((ejercicio) => ejercicio.grupo == selectedGroup)
                    .length,
                itemBuilder: (BuildContext context, int index) {
                  final ejercicio = widget.ejercicios
                      .where((ejercicio) => ejercicio.grupo == selectedGroup)
                      .toList()[index];

                  return ListTile(
                    title: Text(ejercicio.nombre ?? 'Nombre no disponible'),
                    onTap: () {
                      // Agrega aquí la lógica para manejar el tap en el elemento
                    },
                  );
                },
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
              SizedBox(
                width: 200,
              ),
              IconButton(
                onPressed: () {
                  // Acción del segundo botón
                },
                icon: Icon(Icons.save_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
