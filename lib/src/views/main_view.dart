import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainViewApp extends StatefulWidget {
  MainViewApp({Key? key}) : super(key: key);

  @override
  _MainViewAppState createState() => _MainViewAppState();
}

class _MainViewAppState extends State<MainViewApp> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '¡Bienvenido a mi aplicación!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Diálogo de Ejemplo'),
                      content: Text('Esto es un mensaje de ejemplo.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Mostrar Diálogo'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón central
          print('Botón central presionado');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        // Color de fondo personalizado
        elevation: 1.0, // Controla la sombra del botón
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Posición central
      bottomNavigationBar: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            // Cambia estos colores según tus preferencias
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.transparent,
          // Establece el color de la barra de navegación como transparente
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _onItemTapped(0);
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.query_stats_outlined,
                      color: _currentIndex == 0 ? Colors.white : Colors.grey,
                      size: 38,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _onItemTapped(1);
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.person_outline_outlined,
                      color: _currentIndex == 1 ? Colors.white : Colors.grey,
                      size: 38,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
