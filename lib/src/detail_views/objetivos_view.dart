import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_objects/objetivos_firebase.dart';

class ObjetivosGeneralesScreen extends StatefulWidget {
  const ObjetivosGeneralesScreen({super.key});

  @override
  _ObjetivosGeneralesScreenState createState() =>
      _ObjetivosGeneralesScreenState();
}

class _ObjetivosGeneralesScreenState extends State<ObjetivosGeneralesScreen> {
  late Future<List<Objetivos>> _objetivosFuture;
  late DocumentReference
      _misObjetivosRef; // Referencia al documento MisObjetivos
  late Objetivos _objetivoSeleccionado; // Objetivo actualmente seleccionado

  @override
  void initState() {
    super.initState();
    _objetivosFuture = Objetivos.getEjerciciosFromFirebase();
    _misObjetivosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('mis_objetivos')
        .doc('objetivo_actual'); // Referencia al documento objetivo_actual
  }

  // Función para guardar el objetivo seleccionado en la base de datos
  void guardarObjetivoSeleccionado(Objetivos objetivo) async {
    try {
      // Guardar el objetivo en el documento MisObjetivos
      await _misObjetivosRef.set({
        'titulo': objetivo.titulo,
        'descripcion': objetivo.descripcion,
        'beneficios': objetivo.beneficios,
        'imagen': objetivo.imagen,
      });

      // Actualizar el objetivo seleccionado localmente
      setState(() {
        _objetivoSeleccionado = objetivo;
      });

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Objetivo seleccionado correctamente'),
        ),
      );
    } catch (error) {
      // Manejar cualquier error que pueda ocurrir
      print('Error al guardar el objetivo: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar el objetivo'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        title: const Text(
          'OBJETIVOS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 40, 10, 0),
            child: Text(
              '¿CUAL ES TU OBJETIVO?',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Objetivos>>(
              future: _objetivosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final objetivo = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        child: Card(
                          elevation: 4,
                          child: ExpansionTile(
                            leading: objetivo.imagen != null
                                ? Image.network(
                                    objetivo.imagen!,
                                    width: 150,
                                    height: 200,
                                    fit: BoxFit.fitWidth,
                                  )
                                : const SizedBox.shrink(),
                            title: Text(
                              objetivo.titulo,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              ListTile(
                                title: Text(
                                  objetivo.descripcion ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  'Beneficios: ${objetivo.beneficios ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  guardarObjetivoSeleccionado(objetivo);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 3,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(color: Colors.black)),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 2.0),
                                  child: Text(
                                    'SELECCIONAR',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No hay datos disponibles'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
