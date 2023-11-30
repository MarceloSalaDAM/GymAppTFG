import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../firebase_objects/ejercicios_firebase.dart';

class CrearRutinaView extends StatefulWidget {
  final List<Ejercicios> ejercicios;

  const CrearRutinaView({Key? key, required this.ejercicios})
      : super(key: key);

  @override
  _CrearRutinaViewState createState() => _CrearRutinaViewState();
}

class _CrearRutinaViewState extends State<CrearRutinaView> {
  int selectedDias = 3;
  List<Ejercicios> selectedEjercicios = [];
  late String selectedGroup;

  static Future<List<Ejercicios>> cargarEjerciciosDesdeFirebase() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('ejercicios').get();

      return querySnapshot.docs.map((doc) {
        return Ejercicios.fromFirestore(doc, null);
      }).toList();
    } catch (error) {
      print('Error al cargar ejercicios desde Firebase: $error');
      throw error;
    }
  }

  List<String> obtenerGrupos(List<Ejercicios> ejercicios) {
    Set<String> grupos = Set<String>();
    for (var ejercicio in ejercicios) {
      if (ejercicio.grupo != null) {
        grupos.add(ejercicio.grupo!);
      }
    }
    return grupos.toList()..sort();
  }

  List<Ejercicios> obtenerEjerciciosFiltrados() {
    return selectedEjercicios
        .where((ejercicio) => ejercicio.grupo == selectedGroup)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    List<String> grupos = obtenerGrupos(widget.ejercicios);
    selectedGroup = grupos.isNotEmpty ? grupos.first : '';
    cargarEjercicios();
  }
  Future<void> cargarEjercicios() async {
    List<Ejercicios> ejercicios = await cargarEjerciciosDesdeFirebase();
    setState(() {
      selectedEjercicios = ejercicios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Rutina'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Número de días:'),
            DropdownButton<int>(
              value: selectedDias,
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
            DropdownButtonFormField<String>(
              value: selectedGroup,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
              ),
              style: TextStyle(color: Colors.white),
              icon: Icon(Icons.arrow_drop_down, color: Colors.white),
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
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Selecciona ejercicios:'),
            Expanded(
              child: ListView.builder(
                itemCount: obtenerEjerciciosFiltrados().length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title:
                    Text(obtenerEjerciciosFiltrados()[index].nombre ?? ''),
                    value: obtenerEjerciciosFiltrados()[index].isSelected ??
                        false,
                    onChanged: (value) {
                      setState(() {
                        obtenerEjerciciosFiltrados()[index].isSelected = value!;
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                guardarRutina();
              },
              child: Text('Guardar Rutina'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> guardarRutina() async {
    // Implementa la lógica para guardar la rutina con los ejercicios seleccionados y el número de días
    // Puedes utilizar Firebase u otro método según tus necesidades.
    // Por ejemplo, puedes crear una clase `Rutina` que tenga la información necesaria y guardarla en Firebase.
    // Rutina nuevaRutina = Rutina(dias: selectedDias, ejercicios: obtenerEjerciciosFiltrados().where((e) => e.isSelected).toList());
    // await FirebaseService.guardarRutinaEnFirebase(nuevaRutina);
  }
}
