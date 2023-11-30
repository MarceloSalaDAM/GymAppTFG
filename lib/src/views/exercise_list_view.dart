import 'package:flutter/material.dart';
import '../custom/custom_card.dart';
import '../firebase_objects/ejercicios_firebase.dart';

class ExerciseListScreen extends StatefulWidget {
  final List<Ejercicios> ejercicios;

  const ExerciseListScreen({Key? key, required this.ejercicios})
      : super(key: key);

  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late String selectedGroup;

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
    selectedGroup = obtenerGrupos(widget.ejercicios).first;
  }

  @override
  Widget build(BuildContext context) {
    widget.ejercicios
        .sort((a, b) => (a.nombre ?? '').compareTo(b.nombre ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('EJERCICIOS'),
        backgroundColor: const Color(0XFF0f7991),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FILTRAR POR GRUPO MUSCULAR",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedGroup,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors
                        .black, // Cambia el color de fondo del botón según tus necesidades
                  ),
                  style: TextStyle(color: Colors.white),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  // Cambia el color del icono según tus necesidades
                  dropdownColor: Colors.black,
                  // Cambia el color del menú desplegable según tus necesidades
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
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: 120, // Ajusta según sea necesario
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  height: 500, // Ajusta el tamaño según tus necesidades
                  margin: EdgeInsets.all(20),
                  child: PageView.builder(
                    itemCount: widget.ejercicios
                        .where((ejercicio) => ejercicio.grupo == selectedGroup)
                        .length,
                    itemBuilder: (BuildContext context, int index) {
                      final ejercicio = widget.ejercicios
                          .where(
                              (ejercicio) => ejercicio.grupo == selectedGroup)
                          .toList()[index];

                      return CustomCard(ejercicio: ejercicio);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
