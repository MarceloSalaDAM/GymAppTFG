import 'package:flutter/material.dart';
import '../firebase_objects/ejercicios_firebase.dart';

class CustomCard extends StatefulWidget {
  final Ejercicios ejercicio;
  final int currentIndex;
  final int totalItems;

  CustomCard({
    required this.ejercicio,
    required this.currentIndex,
    required this.totalItems,
  });

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isExpanded ? null : 390.0,
        child: Card(
          color: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: const BorderSide(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.totalItems,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == widget.currentIndex - 1 ? 4 : 2,
                    height: index == widget.currentIndex - 1 ? 4 : 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == widget.currentIndex - 1
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.ejercicio.nombre ?? 'Nombre no disponible',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (widget.ejercicio.imagen != null)
                FutureBuilder(
                  future: precacheImage(
                    NetworkImage(widget.ejercicio.imagen!),
                    context,
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      double screenHeight =
                          MediaQuery.of(context).size.height;
                      double imageSize =
                      screenHeight > 800 ? 300.0 : 230.0;

                      return Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.network(
                          widget.ejercicio.imagen!,
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
              const SizedBox(height: 10),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: FadeTransition(
                  opacity: _animation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'EJECUCIÓN:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        widget.ejercicio.descripcion ??
                            'Descripción no disponible',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        alignment: Alignment.centerRight,
                        icon: const Icon(Icons.info_outline_rounded),
                        color: Colors.black,
                        onPressed: _showCommentsDialog,
                      ),
                      const SizedBox(height: 10),
                      if (widget.ejercicio.musculos != null &&
                          widget.ejercicio.musculos!.isNotEmpty)
                        Text(
                          'MÚSCULOS TRABAJADOS:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      Text(
                        widget.ejercicio.musculos!
                            .map((musculo) => '• $musculo\n')
                            .join(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const Text(
                        'TIPO DE EJERCICIO:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        widget.ejercicio.tipo ?? 'Tipo no disponible',
                        style: const TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                secondChild: Container(),
              ),
              const SizedBox(height: 10),
              Icon(
                isExpanded
                    ? Icons.arrow_drop_up_sharp
                    : Icons.arrow_drop_down_sharp,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentsDialog() {
    String comentarios =
        widget.ejercicio.comentarios ?? 'No hay comentarios disponibles';
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
          content: RichText(
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
                  text: comentarios.substring(indexErroresFrecuentes + 18),
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
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

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}