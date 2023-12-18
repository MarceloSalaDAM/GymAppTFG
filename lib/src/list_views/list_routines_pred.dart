import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../detail_views/details_routine_prefabricated.dart';
import '../firebase_objects/rutinas_predeterminadas_firebase.dart';

class RutinasPredView extends StatefulWidget {
  final String nivelSeleccionado;

  const RutinasPredView({Key? key, required this.nivelSeleccionado})
      : super(key: key);

  @override
  _RutinasPredViewState createState() => _RutinasPredViewState();
}

class _RutinasPredViewState extends State<RutinasPredView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<RutinaPredeterminada> rutinasPred = [];
  Color appBarColor = const Color(0XFF0f7991);

  @override
  void initState() {
    super.initState();
    setAppBarColor();
    loadRutinasPredeterminadas();
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

  Future<void> loadRutinasPredeterminadas() async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("rutinas_predeterminadas");

    try {
      // Verificar si la colección existe
      bool collectionExists =
          await collectionRef.get().then((value) => value.size > 0);

      if (collectionExists) {
        // Obtener documentos de la colección existente
        QuerySnapshot snapshot = await collectionRef.get();

        if (snapshot.docs.isNotEmpty) {
          print(
              "Documentos cargados exitosamente para el nivel ${widget.nivelSeleccionado}:");
          snapshot.docs.forEach((doc) {
            print("ID: ${doc.id}, Datos: ${doc.data()}");
          });

          setState(() {
            // Filtrar rutinas por nivel
            rutinasPred = snapshot.docs
                .map((doc) => RutinaPredeterminada.fromFirestore(doc))
                .where((rutina) => rutina.nivelPred == widget.nivelSeleccionado)
                .toList();
          });

          print("Rutinas filtradas para el nivel ${widget.nivelSeleccionado}:");
          rutinasPred.forEach((rutina) {
            print("ID: ${rutina.idPred}, Nombre: ${rutina.nombreRutinaPred}");
          });
        } else {
          print("La colección 'rutinas_predeterminadas' está vacía.");
        }
      } else {
        print("La colección 'rutinas_predeterminadas' no existe en Firebase.");
        // Puedes mostrar un mensaje o realizar otras acciones según tus necesidades.
      }
    } catch (error) {
      print("Error cargando rutinas predeterminadas: $error");
      // Puedes mostrar un mensaje de error o tomar otras medidas según tus necesidades
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: const Text(
          'SELECCIONA LA RUTINA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
        itemCount: rutinasPred.length,
        itemBuilder: (context, index) {
          return _buildRutinaTile(rutinasPred[index], index);
        },
      ),
    );
  }

  Widget _buildRutinaTile(RutinaPredeterminada rutinaPred, int index) {
    return Card(
      color: appBarColor,
      shape: const RoundedRectangleBorder(
        side: BorderSide(),
      ),
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Container(
        child: ExpansionTile(
          title: Text(
            rutinaPred.nombreRutinaPred ?? 'SIN NOMBRE',
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          children: [
            ListTile(
              title: const Text(
                'Descripción:',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              subtitle: Text(
                '${rutinaPred.descripcionRutinaPred}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            _buildDiasList(rutinaPred.diasPred, rutinaPred),
          ],
        ),
      ),
    );
  }

  Widget _buildDiasList(
      Map<String, dynamic> dias, RutinaPredeterminada rutinaPred) {
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

    diasOrdenados.forEach((nombreDia) {
      if (dias.containsKey(nombreDia)) {
        List<Widget> ejerciciosTiles = [];

        tiles.add(
          Container(
            margin: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    nombreDia,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                if (dias[nombreDia]['grupo'] != null)
                  Text(
                    '${dias[nombreDia]['grupo']}',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                const SizedBox(height: 5),
                ...ejerciciosTiles,
              ],
            ),
          ),
        );
      }
    });

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(18.0)),
          ),
          child: Column(
            children: tiles,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetallesRutinaPredeterminadaView(
                      rutinaPred: rutinaPred,
                      nivelSeleccionado: widget.nivelSeleccionado,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await rutinaPred.saveToProfile(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}
