import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EjerciciosDiaView extends StatefulWidget {
  final String dia;
  final Map<String, dynamic> ejerciciosDia;
  final String rutinaId; // Nuevo parámetro

  EjerciciosDiaView(
      {required this.dia, required this.ejerciciosDia, required this.rutinaId});

  @override
  _EjerciciosDiaViewState createState() => _EjerciciosDiaViewState();
}

class _EjerciciosDiaViewState extends State<EjerciciosDiaView> {
  Map<int, bool> _expandedState = {};
  Map<int, TextEditingController> _pesoControllers = {};
  Map<int, TextEditingController> _seriesControllers = {};
  Map<int, TextEditingController> _repeticionesControllers = {};
  Set<int> _ejerciciosEliminados =
      {}; // Variable para almacenar índices de ejercicios eliminados

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los valores reales de los ejercicios
    for (int index = 0;
        index < (widget.ejerciciosDia['ejercicios'] ?? []).length;
        index++) {
      final peso = widget.ejerciciosDia['ejercicios'][index]['peso'] ?? '';
      final series = widget.ejerciciosDia['ejercicios'][index]['series'] ?? '';
      final repeticiones =
          widget.ejerciciosDia['ejercicios'][index]['repeticiones'] ?? '';
      _pesoControllers[index] = TextEditingController(text: '$peso');
      _seriesControllers[index] = TextEditingController(text: '$series');
      _repeticionesControllers[index] =
          TextEditingController(text: '$repeticiones');
    }
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se elimina
    _pesoControllers.forEach((index, controller) {
      controller.dispose();
    });
    _seriesControllers.forEach((index, controller) {
      controller.dispose();
    });
    _repeticionesControllers.forEach((index, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _eliminarEjercicio(String rutinaId, int index) async {
    try {
      // Accede al documento del usuario logueado
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
        FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
        // Elimina el ejercicio del día en la subcolección de rutinas del usuario
        await userDoc.collection('rutinas').doc(rutinaId).update({
          'dias.${widget.dia}.ejercicios': FieldValue.arrayRemove(
              [widget.ejerciciosDia['ejercicios'][index]])
        });
        setState(() {
          widget.ejerciciosDia['ejercicios'].removeAt(index);
          _ejerciciosEliminados
              .add(index); // Agrega el índice del ejercicio eliminado
        });
        print('Ejercicio eliminado exitosamente de la rutina del usuario.');
      } else {
        print('Error: Usuario no logueado.');
      }
    } catch (error) {
      print('Error al eliminar el ejercicio de la rutina del usuario: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.rutinaId);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dia} Ejercicios'),
      ),
      body: ListView.builder(
        itemCount: (widget.ejerciciosDia['ejercicios'] ?? []).length,
        itemBuilder: (context, index) {
          final isExpanded = _expandedState[index] ?? false;

          // Verifica si el índice está en la lista de ejercicios eliminados
          if (_ejerciciosEliminados.contains(index)) {
            return SizedBox
                .shrink(); // Devuelve un widget vacío si el ejercicio fue eliminado
          }

          return Dismissible(
            key: Key(index.toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                // Remove the dismissed item from the list
                widget.ejerciciosDia['ejercicios'].removeAt(index);
                // Also remove the corresponding TextEditingController
                _pesoControllers.remove(index);
                _seriesControllers.remove(index);
                _repeticionesControllers.remove(index);
              });
              // Call _eliminarEjercicio after updating the state to ensure consistency
              _eliminarEjercicio(widget.rutinaId, index);
            },
            direction: isExpanded
                ? DismissDirection.none
                : DismissDirection.endToStart,
            child: Card(
              child: ExpansionTile(
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedState[index] = expanded;
                  });
                },
                title: Text(
                  widget.ejerciciosDia['ejercicios'][index]['nombre'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: isExpanded,
                children: isExpanded
                    ? [
                        ListTile(
                          title: TextField(
                            decoration: InputDecoration(labelText: 'Peso (kg)'),
                            controller: _pesoControllers[index],
                            onChanged: (value) {
                              // Manejar los cambios en el campo de peso aquí
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        ListTile(
                          title: TextField(
                            decoration: InputDecoration(labelText: 'Series'),
                            controller: _seriesControllers[index],
                            onChanged: (value) {
                              // Manejar los cambios en el campo de series aquí
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        ListTile(
                          title: TextField(
                            decoration:
                                InputDecoration(labelText: 'Repeticiones'),
                            controller: _repeticionesControllers[index],
                            onChanged: (value) {
                              // Manejar los cambios en el campo de repeticiones aquí
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ]
                    : [],
              ),
            ),
          );
        },
      ),
    );
  }
}
