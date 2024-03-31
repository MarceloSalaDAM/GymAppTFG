import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../firebase_objects/objetivos_firebase.dart';
import '../firebase_objects/sesiones_firebase.dart';
import 'objetivos_view.dart'; // Asegúrate de importar la clase Sesion desde su ubicación correcta

class StatisticsView extends StatefulWidget {
  const StatisticsView({Key? key}) : super(key: key);

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
    'Mis sesiones',
  ];

  final Map<String, Widget> _contentMap = {
    'Calcular IMC': const Text('Contenido para Calcular IMC'),
    'Mis objetivos': Container(),
    // Contenido para Mis objetivos, se actualizará dinámicamente
    'Mis records': const Text('Contenido para Mis records'),
    'Mi progreso': const Text('Mi progreso'),
    'Notificaciones': const Text('Contenido para Notificaciones'),
    'Mis sesiones': Container(),
    // Contenido para Mis sesiones, se actualiza dinámicamente
  };

  late Widget _selectedContent;
  List<Sesion> _sesiones = []; // Lista de sesiones descargadas
  List<Objetivos> _objetivos = []; // Lista de objetivos descargados
  String _filtroSeleccionado =
      'Fecha más reciente'; // Valor predeterminado del filtro

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _selectedEdad = '';
    _selectedEstatura = '';
    _selectedGenero = '';
    _selectedPeso = '';
    _selectedContent = const Text('Seleccione una opción');
    _loadUserData(); // Cargar datos del usuario al inicio
    _loadSesiones(); // Cargar sesiones al inicio
    _loadObjetivos(); // Cargar objetivos al inicio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  padding: const EdgeInsets.all(5),
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
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 20),
              color: Colors.grey[300],
              padding: const EdgeInsets.all(10),
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
          } else if (title == 'Mis sesiones') {
            _loadSesiones(); // Llama al método para cargar las sesiones del usuario actual
          } else if (title == 'Mis objetivos') {
            setState(() {
              _selectedContent =
                  _buildObjetivosList(); // Actualizar _selectedContent con la lista de objetivos
            });
          } else {
            setState(() {
              _selectedContent =
                  _contentMap[title] ?? const Text('Seleccione una opción');
            });
          }
        },
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0XFF0f7991), Color(0XFF4AB7D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(10), // Ajusta según tu preferencia
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSesionesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilterBar(),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _sesiones.length,
            itemBuilder: (BuildContext context, int index) {
              final sesion = _sesiones[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hora: ${DateFormat.Hm().format(sesion.fecha!)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha: ${DateFormat.yMMMd().format(sesion.fecha!)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duración: ${sesion.duracion ?? ""}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Grupo muscular: ${sesion.grupo ?? ""}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.blueGrey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filtrar por:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<String>(
            value: _filtroSeleccionado,
            onChanged: (String? newValue) {
              setState(() {
                _filtroSeleccionado = newValue!;
                _applyFilter();
              });
            },
            items: <String>[
              'Fecha más reciente',
              'Fecha más antigua',
              'Sesión más larga',
              'Sesión más corta',
              // Agregamos el filtro para la sesión más corta
              'Grupo',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildObjetivosList() {
    if (_objetivos.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("TU OBJETIVO ACTUAL ES:"),
          Expanded(
            child: ListView.builder(
              itemCount: _objetivos.length,
              itemBuilder: (context, index) {
                final objetivo = _objetivos[index];
                return ListTile(
                  title: Text(objetivo.titulo),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ObjetivosGeneralesScreen(),
                ),
              );
            },
            child: Text('Añadir Objetivo'),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Todavía no tienes objetivos.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ObjetivosGeneralesScreen(),
                ),
              );
            },
            child: Text('Añadir'),
          ),
        ],
      );
    }
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

  Future<void> _loadSesiones() async {
    try {
      List<Sesion> sesiones = await Sesion.descargarSesionesUsuarioActual();
      setState(() {
        _sesiones = sesiones;
        _applyFilter(); // Aplicar el filtro inicial
        _selectedContent =
            _buildSesionesList(); // Actualizar el contenido con las sesiones y el filtro
      });
    } catch (error) {
      print('Error al cargar sesiones: $error');
    }
  }

  // En el método _loadObjetivos():
  Future<void> _loadObjetivos() async {
    try {
      final docSnapshot = await _firestore
          .collection("usuarios")
          .doc(_currentUser.uid)
          .collection("mis_objetivos")
          .get();

      // Verificar si existe la subcolección "misobjetivos"
      if (docSnapshot.docs.isNotEmpty) {
        List<Objetivos> objetivos = docSnapshot.docs.map((doc) {
          final data = doc.data();
          return Objetivos(
            // Ajusta las claves según la estructura de tu documento en Firestore
            titulo: data['titulo'] ?? '',
            descripcion: data['descripcion'] ?? '',
            beneficios: data['beneficios'] ?? '',
            imagen: data['imagen'] ?? '',
          );
        }).toList();
        setState(() {
          _objetivos = objetivos;
          // Si existen objetivos, actualizamos _selectedContent con la lista de objetivos
          _selectedContent = _buildObjetivosList();
        });
      } else {
        // Si no existe la subcolección "misobjetivos", mostramos un mensaje fijo
        setState(() {
          _selectedContent = _buildObjetivosList();
        });
      }
    } catch (error) {
      print('Error al cargar objetivos: $error');
    }
  }

  void _applyFilter() {
    switch (_filtroSeleccionado) {
      case 'Fecha más reciente':
        _sesiones.sort((a, b) => b.fecha!.compareTo(a.fecha!));
        break;
      case 'Fecha más antigua':
        _sesiones.sort((a, b) => a.fecha!.compareTo(b.fecha!));
        break;
      case 'Sesión más larga':
        _sesiones
            .sort((a, b) => (b.duracion ?? '').compareTo(a.duracion ?? ''));
        break;
      case 'Sesión más corta':
        _sesiones
            .sort((a, b) => (a.duracion ?? '').compareTo(b.duracion ?? ''));
        break;
      case 'Grupo':
        _sesiones.sort((a, b) => (a.grupo ?? '').compareTo(b.grupo ?? ''));
        break;
    }
    setState(() {
      _selectedContent = _buildSesionesList();
    });
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
