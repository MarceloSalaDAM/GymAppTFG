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
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(10, 30, 10, 50),
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            height: 60,
            width: 400,
            color: Colors.lightBlueAccent,
            child: Text(
              "HOLA! (nombreusuario)",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
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
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {
                  print('Botón central presionado');
                },
                child: Icon(Icons.add, size: 36),
                backgroundColor: Colors.black,
                elevation: 1.0,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  MyBottomNavigationBar({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: Colors.blue,
              height: 3,
            ),
          ),
          GestureDetector(
            onTap: () {
              onItemTapped(0);
            },
            child: Container(
              width: 60,
              child: Icon(
                Icons.home,
                size: 36,
                color: currentIndex == 0 ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.blue,
              height: 3,
            ),
          ),
          GestureDetector(
            onTap: () {
              onItemTapped(1);
            },
            child: Container(
              width: 60,
              child: Icon(
                Icons.search,
                size: 36,
                color: currentIndex == 1 ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.blue,
              height: 3,
            ),
          ),
          GestureDetector(
            onTap: () {
              onItemTapped(2);
            },
            child: Container(
              width: 60,
              child: Icon(
                Icons.person_outline,
                size: 36,
                color: currentIndex == 2 ? Colors.blue : Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.blue,
              height: 3,
            ),
          ),
        ],
      ),
    );
  }
}




