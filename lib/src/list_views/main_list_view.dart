import 'package:flutter/material.dart';

import '../firebase_objects/ejercicios_firebase.dart';
import 'exercise_list_view.dart';
import 'list_routines.dart';

class MainListView extends StatefulWidget {
  final List<Ejercicios> ejercicios;

  const MainListView({Key? key, required this.ejercicios}) : super(key: key);

  @override
  _MainListViewState createState() => _MainListViewState();
}

class _MainListViewState extends State<MainListView> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height > 800 ? 185 : 170;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
            height: containerHeight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
              child: MouseRegion(
                onEnter: (_) => _handleHover(true),
                onExit: (_) => _handleHover(false),
                child: Card(
                  elevation: isHovered ? 8 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/fondotarjeta1.jpg"),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        _showExerciseListScreen(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: Text(
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3.0,
                                      color: Colors.white,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                                'EJERCICIOS',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
            height: containerHeight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
              child: MouseRegion(
                onEnter: (_) => _handleHover(true),
                onExit: (_) => _handleHover(false),
                child: Card(
                  elevation: isHovered ? 8 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/fondotarjeta2.jpg"),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {
                        _showRoutinesListScreen(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: Text(
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3.0,
                                      color: Colors.white,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                                'RUTINAS',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
            height: containerHeight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
              child: MouseRegion(
                onEnter: (_) => _handleHover(true),
                onExit: (_) => _handleHover(false),
                child: Card(
                  elevation: isHovered ? 8 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/fondotarjeta3.jpg"),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: Text(
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 3.0,
                                      color: Colors.white,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                                'NUTRICIÓN',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleHover(bool isHovered) {
    setState(() {
      this.isHovered = isHovered;
    });
  }

  void _showExerciseListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseListScreen(ejercicios: widget.ejercicios),
      ),
    );
  }

  void _showRoutinesListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RutinasUsuarioView(),
      ),
    );
  }
}
