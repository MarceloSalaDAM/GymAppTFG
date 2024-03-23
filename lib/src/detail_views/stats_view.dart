import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsView extends StatefulWidget {
  @override
  _StatisticsViewState createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  // Lista de títulos para cada tarjeta
  final List<String> _titles = [
    'Calcular IMC',
    'Mis objetivos',
    'Mis records',
    'Mi progreso',
    'Título 5',
    'Título 6',
  ];

  // Contenido correspondiente a cada tarjeta
  final Map<String, Widget> _contentMap = {
    'Calcular IMC': Text('Contenido para Calcular IMC'),
    'Mis objetivos': Text('Contenido para Mis objetivos'),
    'Mis records': Text('Contenido para Mis records'),
    'Mi progreso': Text('Mi progreso'),
    'Título 5': Text('Contenido para Título 5'),
    'Título 6': Text('Contenido para Título 6'),
  };

  // Variable para almacenar el contenido seleccionado
  Widget _selectedContent = Text('Seleccione una opción');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primera sección de la pantalla con el grid de tarjetas
          Container(
            color: Colors.blue,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150, // Altura del grid de tarjetas
                  padding:EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: GridView.count(
                    crossAxisCount: 2, // 2 tarjetas por fila
                    childAspectRatio: 4, // Relación de aspecto de las tarjetas
                    children: _buildCards(),
                  ),
                ),
              ],
            ),
          ),
          // Segunda sección de la pantalla
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
              color: Colors.grey[300],
              padding: EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _selectedContent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método para generar las tarjetas
  List<Widget> _buildCards() {
    return _titles.map((title) {
      final index = _titles.indexOf(title);
      return GestureDetector(
        onTap: () {
          // Al pulsar la tarjeta, actualizar el contenido seleccionado
          setState(() {
            _selectedContent = _contentMap[title] ?? Text('Seleccione una opción');
          });
        },
        child: Card(
          color: Colors.blue[100],
          elevation: 3,
          child: Center(
            child: Text(
              title, // Título diferente para cada tarjeta
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
