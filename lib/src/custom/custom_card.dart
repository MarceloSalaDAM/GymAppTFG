import 'package:flutter/material.dart';
import '../firebase_objects/ejercicios_firebase.dart';

class CustomCard extends StatefulWidget {
  final Ejercicios ejercicio;

  CustomCard({required this.ejercicio});

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
      duration: Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: BorderSide(),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${widget.ejercicio.nombre ?? 'Nombre no disponible'}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (widget.ejercicio.imagen != null)
                FutureBuilder(
                  future: precacheImage(
                    NetworkImage(widget.ejercicio.imagen!),
                    context,
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 2.0),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: Image.network(
                          widget.ejercicio.imagen!,
                          width: 230,
                          height: 230,
                          fit: BoxFit.cover,
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _toggleExpansion,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedCrossFade(
                      duration: Duration(milliseconds: 300),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: FadeTransition(
                        opacity: _animation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'EJECUCIÓN:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${widget.ejercicio.descripcion ?? 'Descripción no disponible'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            IconButton(
                              alignment: Alignment.centerRight,
                              icon: Icon(Icons.info_outline_rounded),
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
                              '${widget.ejercicio.musculos!.map((musculo) => '• $musculo\n').join()}',
                              style: TextStyle(
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            Text(
                              'TIPO DE EJERCICIO:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${widget.ejercicio.tipo ?? 'Tipo no disponible'}',
                              style: TextStyle(
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      secondChild:
                          Container(), // Widget vacío cuando está cerrado
                    ),
                    const SizedBox(height: 10),
                    Icon(
                      isExpanded
                          ? Icons.arrow_drop_up_sharp
                          : Icons.arrow_drop_down_sharp,
                      color: Colors.white,
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

  void _showCommentsDialog() {
    String comentarios =
        widget.ejercicio.comentarios ?? 'No hay comentarios disponibles';

    // Buscar la posición de "Errores frecuentes"
    int indexErroresFrecuentes = comentarios.indexOf('Errores frecuentes:');

    // Puedes ajustar el estilo según tus preferencias
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
