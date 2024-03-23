import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  _StatisticsViewState createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  late String _selectedEdad;
  late String _selectedEstatura;
  late String _selectedGenero;
  late String _selectedPeso;

  final List<String> _titles = [
    'Calcular IMC',
    'Mis objetivos',
    'Mis records',
    'Mi progreso',
    'Notificaciones',
    'Título 6',
  ];

  final Map<String, Widget> _contentMap = {
    'Calcular IMC': const Text('Contenido para Calcular IMC'),
    'Mis objetivos': const Text('Contenido para Mis objetivos'),
    'Mis records': const Text('Contenido para Mis records'),
    'Mi progreso': const Text('Mi progreso'),
    'Notificaciones': const Text('Contenido para Notificaciones'),
    'Título 6': const Text('Contenido para Título 6'),
  };

  late Widget _selectedContent;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _selectedEdad = '';
    _selectedEstatura = '';
    _selectedGenero = '';
    _selectedPeso = '';
    _selectedContent = const Text('Seleccione una opción');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  padding: const EdgeInsets.all(10),
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    children: _buildCards(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10),
              color: Colors.grey[300],
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedContent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCards() {
    return _titles.map((title) {
      return GestureDetector(
        onTap: () async {
          if (title == 'Calcular IMC') {
            await _loadUserData();
            _showCalculationResults();
          } else {
            setState(() {
              _selectedContent =
                  _contentMap[title] ?? const Text('Seleccione una opción');
            });
          }
        },
        child: Card(
          color: Colors.blue[100],
          elevation: 3,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _loadUserData() async {
    final docSnap =
        await _firestore.collection("usuarios").doc(_currentUser.uid).get();

    if (docSnap.exists) {
      final userData = docSnap.data() as Map<String, dynamic>;

      setState(() {
        _selectedEdad = userData['edad'] ?? '';
        _selectedGenero = (userData['genero'] ?? '').toString().toLowerCase();
        _selectedEstatura = userData['estatura'] ?? '';
        _selectedPeso = userData['peso'] ?? '';
      });
    }
  }

  void _showCalculationResults() {
    final double imc = _calculateIMC(_selectedPeso, _selectedEstatura);
    final double masaMagra =
        _calculateMasaMagra(_selectedPeso, _selectedEstatura, _selectedGenero);
    final double porcentajeGrasaCorporal =
        _calculatePorcentajeGrasaCorporal(masaMagra, _selectedPeso);
    final double metabolismoBasal = _calculateMetabolismoBasal(
        _selectedPeso, _selectedEstatura, _selectedEdad, _selectedGenero);

    setState(() {
      _selectedContent = _buildResults(
          imc, masaMagra, porcentajeGrasaCorporal, metabolismoBasal);
    });
  }

  double _calculateIMC(String peso, String estatura) {
    final double pesoDouble = double.parse(peso);
    final double estaturaDouble = double.parse(estatura) / 100;
    return pesoDouble / (estaturaDouble * estaturaDouble);
  }

  double _calculateMasaMagra(String peso, String estatura, String genero) {
    final double pesoDouble = double.parse(peso);
    final double estaturaDouble = double.parse(estatura) / 100;

    final double masaMagra = (genero == 'hombre')
        ? (0.32810 * pesoDouble) + (0.33929 * estaturaDouble) - 29.5336
        : (0.29569 * pesoDouble) + (0.41813 * estaturaDouble) - 43.2933;

    return masaMagra;
  }

  double _calculatePorcentajeGrasaCorporal(double masaMagra, String peso) {
    final double pesoDouble = double.parse(peso);
    return ((pesoDouble - masaMagra) / pesoDouble) * 100;
  }

  double _calculateMetabolismoBasal(
      String peso, String estatura, String edad, String genero) {
    final double pesoDouble = double.parse(peso);
    final double estaturaDouble = double.parse(estatura);
    final double edadDouble = double.parse(edad);

    final double metabolismoBasal = (genero == 'hombre')
        ? 88.362 +
            (13.397 * pesoDouble) +
            (4.799 * estaturaDouble) -
            (5.677 * edadDouble)
        : 447.593 +
            (9.247 * pesoDouble) +
            (3.098 * estaturaDouble) -
            (4.330 * edadDouble);

    return metabolismoBasal;
  }

  Widget _buildResults(double imc, double masaMagra,
      double porcentajeGrasaCorporal, double metabolismoBasal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Resultados:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        _buildResultItem('IMC', imc.toStringAsFixed(2)),
        _buildResultItem('Masa Magra', masaMagra.toStringAsFixed(2)),
        _buildResultItem('Porcentaje de Grasa Corporal',
            '${porcentajeGrasaCorporal.toStringAsFixed(2)}%'),
        _buildResultItem(
            'Metabolismo Basal', metabolismoBasal.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
