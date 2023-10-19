import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app_tfg/src/views/profile_view.dart';

import '../custom/card_item.dart';

class MainViewApp extends StatefulWidget {
  const MainViewApp({Key? key}) : super(key: key);

  @override
  _MainViewAppState createState() => _MainViewAppState();
}

class _MainViewAppState extends State<MainViewApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = ''; // Variable para almacenar el nombre del usuario

  @override
  void initState() {
    super.initState();
    _loadUserName();
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

  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HOLA! $userName', // Muestra el nombre del usuario aquí
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 10, 5),
            child: IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 37,
              onPressed: () {
                Navigator.of(context).popAndPushNamed("/Settings");
                print('Botón presionado');
              },
            ),
          ),
        ],
      ),
      body: _currentIndex == 1
          ? Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'HOLA! $userName', // Muestra el nombre del usuario aquí
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: CardListView(
                      cards: [
                        CardModel('Carta 1', 'Descripción de la Carta 1'),
                        CardModel('Carta 2', 'Descripción de la Carta 2'),
                        CardModel('Carta 3', 'Descripción de la Carta 3'),
                      ],
                      onCardTap: (card) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CardDetail(card),
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
                  ? const ProfileView()
                  : Container(),
      // Widget vacío para otras pestañas
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
            // Eliminar la sombra
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
