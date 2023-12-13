import 'package:flutter/material.dart';
import 'package:gym_app_tfg/src/custom/rotating_card_custom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<Ejercicios> ejerciciosFavoritos = [];
  late PageController _pageController;
  Ejercicios? ejercicioActual;

  List<String> obtenerGrupos(List<Ejercicios> ejercicios) {
    Set<String> grupos = Set<String>();
    for (var ejercicio in ejercicios) {
      if (ejercicio.grupo != null) {
        grupos.add(ejercicio.grupo!);
      }
    }
    print('Grupos encontrados: $grupos');
    return grupos.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    List<String> grupos = obtenerGrupos(widget.ejercicios);
    print('Grupos disponibles: $grupos');

    selectedGroup = grupos.isNotEmpty ? grupos.first : '';
    print('Selected Group: $selectedGroup');
  }

  Future<void> handleFavoriteAction(Ejercicios ejercicio) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userRef =
      FirebaseFirestore.instance.collection('usuarios').doc(userId);
      final favoritosRef = userRef.collection('ejercicios_favoritos');

      // Comprobar si el ejercicio ya está en favoritos
      final snapshot = await favoritosRef.doc(ejercicio.uid!).get();

      setState(() {
        if (snapshot.exists) {
          // El ejercicio está en favoritos, así que lo eliminamos
          ejerciciosFavoritos.remove(ejercicio);
          favoritosRef.doc(ejercicio.uid!).delete();
        } else {
          // El ejercicio no está en favoritos, así que lo añadimos
          ejerciciosFavoritos.add(ejercicio);
          favoritosRef.doc(ejercicio.uid!).set({
            'nombre': ejercicio.nombre,
            'grupo': ejercicio.grupo,
            // Agrega más campos según sea necesario
          });
        }
        ejercicioActual = ejercicio;

      });
    }

    // Mostrar SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ejerciciosFavoritos.contains(ejercicio)
              ? 'Ejercicio agregado a favoritos'
              : 'Ejercicio eliminado de favoritos',
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Print para verificar la lista después de cada toggle
    print('Ejercicio Favorito: ${ejercicio.nombre}');
  }

  void onPageChanged(int index) {
    final ejercicio = widget.ejercicios
        .where((ejercicio) => ejercicio.grupo == selectedGroup)
        .toList()[index];
    setState(() {
      ejercicioActual = ejercicio;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.ejercicios
        .sort((a, b) => (a.nombre ?? '').compareTo(b.nombre ?? ''));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EJERCICIOS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0XFF0f7991),
      ),
      body: SingleChildScrollView(
        child: ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "FILTRAR POR GRUPO MUSCULAR",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),
                    DropdownButtonFormField<String>(
                      value: selectedGroup,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.white),
                      dropdownColor: Colors.black,
                      onChanged: (value) {
                        setState(() {
                          selectedGroup = value!;
                          _pageController.jumpToPage(
                              0); // Sin necesidad de mantener en el estado local
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
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height > 800
                            ? 450
                            : 500,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.ejercicios
                              .where((ejercicio) =>
                          ejercicio.grupo == selectedGroup)
                              .length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: RotatingCard(
                                ejercicio: widget.ejercicios
                                    .where((ejercicio) =>
                                ejercicio.grupo == selectedGroup)
                                    .toList()[index],
                                currentIndex: index + 1,
                                totalItems: widget.ejercicios
                                    .where((ejercicio) =>
                                ejercicio.grupo == selectedGroup)
                                    .length,
                              ),
                            );
                          },
                          onPageChanged: onPageChanged,
                        ),
                      ),
                    ),
                  ],
                ),
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
              const SizedBox(
                width: 200,
              ),
              IconButton(
                onPressed: () {
                  print('Button pressed');
                  // Accede al ejercicio actual desde la variable global
                  if (ejercicioActual != null) {
                    print('Ejercicio actual is not null');
                    handleFavoriteAction(ejercicioActual!);
                  } else {
                    print(
                        'Ejercicio actual is null. Cannot handle favorite action.');
                  }
                },
                icon: Icon(Icons.favorite),
              ),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                onPressed: () {
                  // Acción del segundo botón
                },
                icon: Icon(Icons.add_sharp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}