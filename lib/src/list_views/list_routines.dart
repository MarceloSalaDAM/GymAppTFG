import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../firebase_objects/rutinas_firebase.dart';
import '../detail_views/details_routine.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class RutinasUsuarioView extends StatefulWidget {
  const RutinasUsuarioView({super.key});

  @override
  _RutinasUsuarioViewState createState() => _RutinasUsuarioViewState();
}

class _RutinasUsuarioViewState extends State<RutinasUsuarioView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Rutina> rutinas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      loadUserData();
    });
  }

  // Carga de datos de usuario y rutinas asociadas
  Future<void> loadUserData() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    final docRef = db.collection("usuarios").doc(idUser);

    // Establecer _isLoading en true antes de cargar los datos
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot docsnap = await docRef.get();

    if (docsnap.exists) {
      // Cargar datos de usuario
      Map<String, dynamic> userData = docsnap.data() as Map<String, dynamic>;
      setState(() {
        // Aquí puedes manejar los datos del usuario si es necesario
      });

      // Obtener la subcolección de rutinas asociadas al usuario
      final rutinasRef = docRef.collection('rutinas');
      final rutinasSnap = await rutinasRef.get();

      setState(() {
        rutinas =
            rutinasSnap.docs.map((doc) => Rutina.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        title: const Text(
          'TUS RUTINAS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : rutinas.isEmpty
              ? const Center(
                  child: Text(
                    'Todavía no tienes rutinas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  itemCount: rutinas.length,
                  itemBuilder: (context, index) {
                    return _buildRutinaTile(rutinas[index], index);
                  },
                ),
    );
  }

  Widget _buildRutinaTile(Rutina rutina, int index) {
    return Card(
      color: Colors.blueGrey,
      shape: const RoundedRectangleBorder(
        side: BorderSide(),
      ),
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: ExpansionTile(
        title: Text(
          rutina.nombreRutina ?? 'SIN NOMBRE',
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
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
              '${rutina.descripcionRutina}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
          _buildDiasList(rutina.dias, rutina),
        ],
      ),
    );
  }

  Widget _buildDiasList(Map<String, dynamic> dias, Rutina rutina) {
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

        if (dias[nombreDia]['grupo'] != null) {
          ejerciciosTiles.add(
            Text(
              '${dias[nombreDia]['grupo']}',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          );
        }

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
                    builder: (context) => DetallesRutinaView(rutina: rutina),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                _descargarRutina(rutina);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () {
                print("ID de la rutina a eliminar: ${rutina.id}");

                // Lógica para eliminar la rutina
                _showDeleteConfirmationDialog(rutina);
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _descargarRutina(Rutina rutina) async {
    final pdf = pw.Document();

    // Definir la imagen estática
    final image = pw.MemoryImage(
      (await rootBundle.load('assets/pdflogo.jpg'))
          .buffer
          .asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return <pw.Widget>[
            // Agregar la imagen estática
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Image(image),
            ),
            pw.Header(
              level: 1,
              textStyle: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue),
              child: pw.Text(rutina.nombreRutina ?? 'SIN NOMBRE'),
            ),
            // Descripción de la rutina con estilo personalizado
            pw.Paragraph(
              style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
              text: rutina.descripcionRutina ?? '',
            ),
            // Lista de días y ejercicios
            for (var dia in rutina.dias.keys)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Título del día con estilo personalizado
                  pw.Header(
                    level: 2,
                    textStyle: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green),
                    child: pw.Text(dia),
                  ),
                  // Lista de ejercicios y detalles
                  for (var ejercicio in rutina.dias[dia]['ejercicios'])
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Nombre del ejercicio con estilo personalizado
                        pw.Text(
                          ejercicio['nombre'] ?? '',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        // Detalles del ejercicio (peso, series, repeticiones) con estilo personalizado
                        pw.Row(
                          children: [
                            if (ejercicio.containsKey('peso'))
                              pw.Text('Peso: ${ejercicio['peso']}'),
                            if (ejercicio.containsKey('series'))
                              pw.Text('Series: ${ejercicio['series']}'),
                            if (ejercicio.containsKey('repeticiones'))
                              pw.Text(
                                  'Repeticiones: ${ejercicio['repeticiones']}'),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
          ];
        },
      ),
    );

    // Agregar marca de agua
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Transform.rotate(
              angle: -0.5, // Ángulo de rotación de la marca de agua
              child: pw.Text(
                'Confidencial',
                style: pw.TextStyle(fontSize: 50, color: PdfColors.grey),
              ),
            ),
          );
        },
      ),
    );

    // Obtener el directorio de descargas del dispositivo
    final directory = await getDownloadsDirectory();
    final path = '${directory?.path}/rutina_${rutina.id}.pdf';

    // Guardar el PDF en el directorio de descargas
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    // Verificar si el archivo se guardó correctamente
    if (await file.exists()) {
      print('PDF guardado correctamente en: $path');
      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rutina descargada exitosamente'),
          duration: Duration(milliseconds: 2000),
        ),
      );
    } else {
      print('Error al guardar el PDF.');
      // Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al descargar la rutina'),
          duration: Duration(milliseconds: 2000),
        ),
      );
    }
  }

  // Función para mostrar un cuadro de diálogo de confirmación antes de eliminar
  Future<void> _showDeleteConfirmationDialog(Rutina rutina) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          // Evitar que se cierre el diálogo con el botón de retroceso del dispositivo
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: const Text(
              'ELIMINAR RUTINA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ),
            content:
                const Text('¿Estás seguro de que deseas borrar la rutina?'),
            actions: <Widget>[
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'CANCELAR',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0), // Ajusta el espacio entre los botones
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Lógica para eliminar la rutina
                        await rutina.deleteFromFirestore();
                        // Actualizar la vista
                        setState(() {
                          rutinas.remove(rutina);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('RUTINA BORRADA'),
                            duration: Duration(milliseconds: 2000),
                          ),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        print("Error al eliminar la rutina: $e");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'ELIMINAR',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
