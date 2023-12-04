import 'package:flutter/material.dart';
import 'package:gym_app_tfg/src/custom/rotating_card_custom.dart';

import '../firebase_objects/ejercicios_firebase.dart';
import 'exercise_list_view.dart';

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
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            height: 200,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                      image: DecorationImage(
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
                        padding: EdgeInsets.all(10.0), // Adjust the padding
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
                                  'EJERCICIOS'),
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
            height: 200,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                      image: DecorationImage(
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
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10.0), // Adjust the padding
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
                                  'RUTINAS'),
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

}
