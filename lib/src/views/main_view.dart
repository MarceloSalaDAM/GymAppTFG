import 'package:flutter/material.dart';

class MainViewApp extends StatefulWidget {
  MainViewApp({Key? key}) : super(key: key);

  @override
  _MainViewAppState createState() => _MainViewAppState();
}

class _MainViewAppState extends State<MainViewApp> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    // Contenido para la página de estadísticas
    Container(
      color: Colors.blue,
      child: Center(
        child: Text(
          'Progreso',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    ),
    // Contenido para la página de inicio
    Container(
      color: Colors.blue,
      child: Center(
        child: Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    ),
    // Contenido para la página de perfil
    Container(
      color: Colors.blue,
      child: Center(
        child: Text(
          'Perfil',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 10, 5),
            child: IconButton(
              icon: Icon(Icons.settings),
              iconSize: 37,
              onPressed: () {
                Navigator.of(context).popAndPushNamed("/Settings");
                print('Botón presionado');
              },
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 90,
        margin: EdgeInsets.fromLTRB(5, 5, 5, 15),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
            elevation: 0.0, // Eliminar la sombra
            backgroundColor: Colors.transparent,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            items: [
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción cuando se presiona el botón flotante
        },
        child: Icon(Icons.add,size: 40),
        backgroundColor: Colors.black,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}