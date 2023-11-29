import 'package:flutter/material.dart';
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
    widget.ejercicios.sort((a, b) => (a.nombre ?? '').compareTo(b.nombre ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('EJERCICIOS'),
        backgroundColor: const Color(0XFF0f7991),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedGroup,
              hint: Text('Seleccionar Grupo'),
              onChanged: (value) {
                setState(() {
                  selectedGroup = value!;
                });
              },
              items: obtenerGrupos(widget.ejercicios).map((grupo) {
                return DropdownMenuItem<String>(
                  value: grupo,
                  child: Text(grupo),
                );
              }).toList(),
            ),
            SizedBox(
              height: 800, // Altura del carrusel
              child: PageView.builder(
                itemCount: widget.ejercicios
                    .where((ejercicio) =>
                selectedGroup == null ||
                    ejercicio.grupo == selectedGroup)
                    .length,
                itemBuilder: (BuildContext context, int index) {
                  final ejercicio = widget.ejercicios
                      .where((ejercicio) =>
                  selectedGroup == null ||
                      ejercicio.grupo == selectedGroup)
                      .toList()[index];

                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ejercicio.imagen != null)
                          FutureBuilder(
                            future: precacheImage(
                                NetworkImage(ejercicio.imagen!), context),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Image.network(ejercicio.imagen!);
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        Text(
                            '***Nombre: ${ejercicio.nombre ?? 'Nombre no disponible'}'),
                        Text(
                            '***Descripción: ${ejercicio.descripcion ?? 'Descripción no disponible'}'),
                        Text(
                            '***Comentarios: ${ejercicio.comentarios ?? 'Comentarios no disponibles'}'),
                        Text(
                            '***Grupo: ${ejercicio.grupo ?? 'Grupo no disponible'}'),
                        Text(
                            '***Tipo: ${ejercicio.tipo ?? 'Tipo no disponible'}'),
                        if (ejercicio.musculos != null &&
                            ejercicio.musculos!.isNotEmpty)
                          Text(
                              '***Músculos: ${ejercicio.musculos!.join(", ")}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
