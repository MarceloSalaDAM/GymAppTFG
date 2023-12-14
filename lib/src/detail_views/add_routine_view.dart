import 'package:flutter/material.dart';

class SelectTrainingLevelView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        title: Text(
          'SELECCIONA TU NIVEL',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¡Bienvenido a EasyFit! Queremos personalizar tu experiencia según tu nivel actual. Por favor, elige uno de los siguientes niveles:',
                    style: TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  buildLevelTextAndButton(
                    'PRINCIPIANTE:',
                    'Si estás comenzando tu viaje fitness, este nivel es perfecto para ti. Aquí encontrarás rutinas diseñadas para construir una base sólida y desarrollar hábitos saludables.',
                    'PRINCIPIANTE',
                    Colors.green,
                        () {
                      Navigator.of(context).pushNamed('/Main');
                    },
                  ),
                  Divider(height: 16.0),
                  buildLevelTextAndButton(
                    'INTERMEDIO:',
                    'Para aquellos que ya han avanzado en su viaje, el nivel intermedio ofrece desafíos más intensos. Prepárate para mejorar tu resistencia y fuerza con entrenamientos específicos.',
                    'INTERMEDIO',
                    Colors.orange,
                        () {
                      Navigator.of(context).pushNamed('/DetailsRoutinePredIntermediate');
                    },
                  ),
                  Divider(height: 16.0),
                  buildLevelTextAndButton(
                    'AVANZADO:',
                    'Si eres un atleta experimentado, el nivel avanzado te desafiará al máximo. Descubre rutinas diseñadas para personas con un alto nivel de condición física y metas ambiciosas.',
                    'AVANZADO',
                    Colors.red,
                        () {
                      Navigator.of(context).pushNamed('/DetailsRoutinePredAdvanced');
                    },
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLevelTextAndButton(
      String title,
      String description,
      String buttonText,
      Color buttonColor,
      VoidCallback onPressed,
      ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Text(
          description,
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
