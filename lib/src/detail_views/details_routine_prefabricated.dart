import 'package:flutter/material.dart';

import '../firebase_objects/rutinas_predeterminadas_firebase.dart';

class DetallesRutinaPredeterminadaView extends StatefulWidget {
  RutinaPredeterminada rutinaPred;
  final String nivelSeleccionado;

  DetallesRutinaPredeterminadaView(
      {Key? key, required this.rutinaPred, required this.nivelSeleccionado})
      : super(key: key);

  @override
  _DetallesRutinaPredeterminadaViewState createState() =>
      _DetallesRutinaPredeterminadaViewState();
}

class _DetallesRutinaPredeterminadaViewState
    extends State<DetallesRutinaPredeterminadaView> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  Color appBarColor = const Color(0XFF0f7991);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
    setAppBarColor();
  }

  void setAppBarColor() {
    // Cambiar el color del AppBar según el nivel
    if (widget.nivelSeleccionado == "Principiante") {
      appBarColor = Colors.green; // Puedes cambiar a otro color
    } else if (widget.nivelSeleccionado == "Intermedio") {
      appBarColor = Colors.orange; // Puedes cambiar a otro color
    } else if (widget.nivelSeleccionado == "Avanzado") {
      appBarColor = Colors.red; // Puedes cambiar a otro color
    }
  }

  @override
  Widget build(BuildContext context) {
    final diasOrdenados = [
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO',
      'DOMINGO'
    ];

    final diasPresentes = diasOrdenados.where((dia) {
      return widget.rutinaPred.diasPred.containsKey(dia);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.rutinaPred.nombreRutinaPred}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          height: 800,
          margin: const EdgeInsets.fromLTRB(15, 25, 15, 50),
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      currentPage = page;
                    });
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: diasPresentes.length,
                  itemBuilder: (context, index) {
                    final diaEnMayusculas = diasPresentes[index];
                    final dias = widget.rutinaPred.diasPred;
                    final ejerciciosDia = dias[diaEnMayusculas];

                    return Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      constraints: const BoxConstraints(maxHeight: 800),
                      child: SingleChildScrollView(
                        child: _buildDiasList({diaEnMayusculas: ejerciciosDia}),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(diasPresentes.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      child: CircleAvatar(
                        backgroundColor:
                            currentPage == index ? Colors.black : Colors.grey,
                        radius: currentPage == index ? 15 : 10,
                        child: Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiasList(Map<String, dynamic> dias) {
    List<Widget> tiles = [];

    final diasOrdenados = [
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO',
      'DOMINGO'
    ];

    for (var nombreDia in diasOrdenados) {
      final diaEnMayusculas = nombreDia;

      if (dias.containsKey(diaEnMayusculas)) {
        List<Widget> ejerciciosTiles = [];

        if (dias[diaEnMayusculas]['ejercicios'] != null) {
          ejerciciosTiles.add(
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ejercicios',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          );

          for (var ejercicio in dias[diaEnMayusculas]['ejercicios']) {
            ejerciciosTiles.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ${ejercicio['nombre']}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        '\t\t\tSeries: ',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                      Text(
                        '${ejercicio['series']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '\t\t\tRepeticiones: ',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                      Text(
                        '${ejercicio['repeticiones']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        '\t\t\tPeso: ',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        '${ejercicio['peso']} kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    // Agrega un Divider
                    height: 20,
                    color: Colors.grey,
                  ),
                ],
              ),
            );
          }
        }

        tiles.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diaEnMayusculas,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 27.0,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                ' ⚠ No olvides calentar antes de comenzar',
                style: TextStyle(
                  color: Color(0XFF0f7991),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '⏱ Los descansos son muy importantes para realizar un buen entrenamiento',
                style: TextStyle(
                  color: Color(0XFF0f7991),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                ),
              ),
              const SizedBox(height: 8.0),
              ...ejerciciosTiles,
            ],
          ),
        );
      }
    }

    return Column(
      children: tiles,
    );
  }
}
