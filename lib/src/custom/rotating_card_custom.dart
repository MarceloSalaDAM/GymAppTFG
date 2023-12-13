import 'package:flutter/material.dart';

import '../firebase_objects/ejercicios_firebase.dart';

class RotatingCard extends StatefulWidget {
  final Ejercicios ejercicio;
  final int currentIndex;
  final int totalItems;

  RotatingCard({
    required this.ejercicio,
    required this.currentIndex,
    required this.totalItems,
  });

  @override
  _RotatingCardState createState() => _RotatingCardState();
}

class _RotatingCardState extends State<RotatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool isFront = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation =
        Tween<double>(begin: 0, end: 180).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            GestureDetector(
              onTap: _toggleCard,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(_animation.value * (3.1415927 / 180)),
                    alignment: Alignment.center,
                    child: Card(
                      elevation: 4,
                      color: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        side: const BorderSide(),
                      ),
                      child: isFront
                          ? FrontCard(
                              ejercicio: widget.ejercicio,
                              currentIndex: widget.currentIndex,
                              totalItems: widget.totalItems,
                            )
                          : BackCard(
                              ejercicio: widget.ejercicio,
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCard() {
    if (isFront) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isFront = !isFront;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class FrontCard extends StatelessWidget {
  final Ejercicios ejercicio;
  final int currentIndex;
  final int totalItems;

  FrontCard({
    required this.ejercicio,
    required this.currentIndex,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalItems,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == currentIndex - 1 ? 4 : 2,
                height: index == currentIndex - 1 ? 4 : 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == currentIndex - 1 ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ejercicio.nombre ?? 'Nombre no disponible',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (ejercicio.imagen != null)
            FutureBuilder(
              future: precacheImage(
                NetworkImage(ejercicio.imagen!),
                context,
              ),
              builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  double screenHeight = MediaQuery.of(context).size.height;
                  double imageSize = screenHeight > 800 ? 280.0 : 230.0;

                  return Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      ejercicio.imagen!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
        ],
      ),
    );
  }
}

class BackCard extends StatelessWidget {
  final Ejercicios ejercicio;

  BackCard({
    required this.ejercicio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.blueGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildRotatedText(
                  'EJECUCIÓN:',
                  ejercicio.descripcion ?? 'Descripción no disponible',
                ),
                const SizedBox(height: 10),
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: const Icon(Icons.info_outline_rounded),
                  color: Colors.black,
                  onPressed: () {
                    // Llama a la función _showCommentsDialog al presionar el ícono
                    _showCommentsDialog(context);
                  },
                ),
                const SizedBox(height: 10),
                if (ejercicio.musculos != null &&
                    ejercicio.musculos!.isNotEmpty)
                  _buildRotatedText(
                    'MÚSCULOS TRABAJADOS:',
                    ejercicio.musculos!.map((musculo) => '• $musculo\n').join(),
                  ),
                const SizedBox(height: 10),
                _buildRotatedText(
                  'TIPO DE EJERCICIO:',
                  ejercicio.tipo ?? 'Tipo no disponible',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRotatedText(String title, String text) {
    return Column(
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(3.1415927),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 5),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(3.1415927),
          child: Container(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  // Agrega la función _showCommentsDialog aquí
  void _showCommentsDialog(BuildContext context) {
    String comentarios =
        ejercicio.comentarios ?? 'No hay comentarios disponibles';
    int indexErroresFrecuentes = comentarios.indexOf('Errores frecuentes:');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'COMENTARIOS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      if (indexErroresFrecuentes != -1)
                        TextSpan(
                          text:
                              '${comentarios.substring(0, indexErroresFrecuentes)}\n',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),
                      if (indexErroresFrecuentes != -1)
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.warning,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      if (indexErroresFrecuentes != -1)
                        const TextSpan(
                          text: 'Errores frecuentes',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      TextSpan(
                        text:
                            comentarios.substring(indexErroresFrecuentes + 18),
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'CERRAR',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
