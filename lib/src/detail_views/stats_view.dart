import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsView extends StatefulWidget {
  @override
  _StatisticsViewState createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8), // Margen superior para el texto
              child: const Text(
                'Contenido de Estadísticas',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Aquí colocaremos la gráfica
            Container(
              height: 300, // Altura suficiente para mostrar la gráfica
              padding: EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 4),
                        FlSpot(2, 3.5),
                        FlSpot(3, 5),
                        FlSpot(4, 4),
                        FlSpot(5, 6),
                        FlSpot(6, 5),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minY: 0,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(),
                    bottomTitles: AxisTitles(),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFE4E8EB),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: const Color(0xFFE4E8EB),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
