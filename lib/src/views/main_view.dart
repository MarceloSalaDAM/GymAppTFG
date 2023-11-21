import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app_tfg/src/views/profile_view.dart';
import 'package:gym_app_tfg/src/views/settings.dart';

import '../custom/card_item.dart';
import '../custom/custom_drawer.dart';
import '../firebase_objects/ejercicios_firebase.dart';
import 'details_profile_view.dart';

class MainViewApp extends StatefulWidget {
  const MainViewApp({Key? key}) : super(key: key);

  @override
  _MainViewAppState createState() => _MainViewAppState();
}

class _MainViewAppState extends State<MainViewApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = ''; // Variable para almacenar el nombre del usuario
  List<Ejercicios> ejercicios = []; // Lista para almacenar los ejercicios

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadEjercicios();
  }

  Future<void> _loadUserName() async {
    final user = _auth.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      final docRef = _firestore.collection("usuarios").doc(uid);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          userName = data['nombre'] ?? '';
        });
      }
      // Escuchar cambios en el documento del usuario y actualizar en tiempo real
      docRef.snapshots().listen((event) {
        if (event.exists) {
          final data = event.data() as Map<String, dynamic>;
          setState(() {
            userName = data['nombre'] ?? '';
          });
        }
      });
    }
  }

  Future<void> _loadEjercicios() async {
    final docRef = _firestore.collection("ejercicios");

    final docsSnap = await docRef.get();

    setState(() {
      ejercicios = docsSnap.docs.map((doc) {
        return Ejercicios.fromFirestore(
            doc, null); // Convierte el documento en un objeto Ejercicios
      }).toList();
    });
  }

  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 1
            ? Text(
                'HOLA! $userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            : _currentIndex == 2
                ? const Text(
                    'PERFIL',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      endDrawer: _currentIndex == 2
          ? CustomDrawer(onLanguageChanged: (String language) {})
          : null,
      body: _currentIndex == 1
          ? Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: ListView.builder(
                      itemCount: ejercicios.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ejercicio = ejercicios[index];
                        return Card(
                          child: ListTile(
                            leading: ejercicio.imagen != null
                                ? Image.network(ejercicio.imagen!)
                                : Text("No foto"),
                            title: Text(
                                ejercicio.nombre ?? 'Nombre no disponible'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '***Descripción: ${ejercicio.descripcion ?? 'Descripción no disponible'}'),
                                Text(
                                    '***Comentarios: ${ejercicio.comentarios ?? 'Comentarios no disponibles'}'),
                                Text(
                                    '***Grupo: ${ejercicio.grupo ?? 'Grupo no disponible'}'),
                                if (ejercicio.musculos != null &&
                                    ejercicio.musculos!.isNotEmpty)
                                  Text(
                                      '***Músculos: ${ejercicio.musculos!.join(", ")}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : _currentIndex == 0
              ? const Center(
                  child: Text(
                    'Contenido de Estadísticas',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                )
              : _currentIndex == 2
                  ? const DetailsProfileView()
                  : Container(),
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 15),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.query_stats),
                label: 'PROGRESO',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'INICIO',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'PERFIL',
              ),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            iconSize: 30,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.black,
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 1
          ? Tooltip(
              message: 'Añadir nueva rutina',
              child: FloatingActionButton(
                onPressed: () {
                  // Acción cuando se presiona el botón flotante
                },
                backgroundColor: Colors.black,
                child: const Icon(Icons.add, size: 40),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
