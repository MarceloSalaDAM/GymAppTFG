import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: const LinearGradient(
            colors: [Color(0XFF0f7991), Color(0XFF4AB7D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          title: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              rutina.nombreRutina ?? 'SIN NOMBRE',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          children: [
            ListTile(
              title: const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  'Descripción:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  '${rutina.descripcionRutina}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _buildDiasList(rutina.dias, rutina),
          ],
        ),
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
    // Obtener el directorio de descargas del dispositivo
    final directory = await getDownloadsDirectory();
    String fileName = 'rutina_${rutina.nombreRutina}.pdf';

    // Verificar si el archivo ya existe en el directorio de descargas
    if (directory != null) {
      int suffix = 1;
      while (await File('${directory.path}/$fileName').exists()) {
        fileName = 'rutina_${rutina.nombreRutina}(${suffix++}).pdf';
      }
    }

    final pdf = pw.Document();

    // Definir la imagen estática
    final image = pw.MemoryImage(
      (await rootBundle.load('assets/pdflogo.jpg')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final List<pw.Widget> content = [];

          content.add(
            pw.Container(
              alignment: pw.Alignment.topLeft,
              width: 100, // Ancho deseado de la imagen
              height: 100, // Alto deseado de la imagen
              child: pw.Image(image),
            ),
          );

          // Título grande y centrado para el nombre de la rutina
          content.add(
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text(
                rutina.nombreRutina ?? 'SIN NOMBRE',
                style: pw.TextStyle(
                  fontSize: 44,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ),
          );

          // Espacio entre el título y la descripción
          content.add(pw.SizedBox(height: 20));

          // Descripción de la rutina con tamaño de fuente más pequeño y alineación izquierda
          content.add(
            pw.Container(
              alignment: pw.Alignment.topLeft,
              child: pw.Text(
                rutina.descripcionRutina ?? '',
                style: pw.TextStyle(
                  fontSize: 28,
                  color: PdfColors.black,
                ),
              ),
            ),
          );

          // Espacio entre la descripción y la tabla de días y ejercicios
          content.add(pw.SizedBox(height: 20));
          content.add(pw.Divider(height: 20));
          content.add(pw.SizedBox(height: 20));

          // Ordenar los días de la rutina de lunes a domingo
          final diasSemana = [
            'LUNES',
            'MARTES',
            'MIÉRCOLES',
            'JUEVES',
            'VIERNES',
            'SÁBADO',
            'DOMINGO'
          ];
          for (var dia in diasSemana) {
            if (rutina.dias.containsKey(dia)) {
              content.add(
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.topLeft,
                      child: pw.Text(
                        '${dia}${rutina.dias[dia]['grupo'] != null ? ': ${rutina.dias[dia]['grupo']}' : ''}',
                        style: pw.TextStyle(
                          fontSize: 25,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    // Tabla de ejercicios y detalles
                    pw.TableHelper.fromTextArray(
                      border: pw.TableBorder.all(),
                      cellAlignment: pw.Alignment.centerLeft,
                      headerAlignment: pw.Alignment.centerLeft,
                      cellStyle: pw.TextStyle(fontSize: 16),
                      headerStyle: pw.TextStyle(
                        fontSize: 19,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      data: [
                        // Encabezado de la tabla
                        ['Ejercicio', 'Peso', 'Series', 'Repeticiones'],
                        // Filas de datos de ejercicios
                        for (var ejercicio in rutina.dias[dia]['ejercicios'])
                          [
                            ejercicio['nombre'] ?? '',
                            ejercicio.containsKey('peso')
                                ? '${ejercicio['peso']} kg'
                                : '',
                            ejercicio.containsKey('series')
                                ? ejercicio['series'].toString()
                                : '',
                            ejercicio.containsKey('repeticiones')
                                ? ejercicio['repeticiones'].toString()
                                : '',
                          ],
                      ],
                    ),
                    pw.SizedBox(height: 20),
                  ],
                ),
              );
            }
          }

          return content;
        },
      ),
    );

    final path = '${directory?.path}/$fileName';

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
                      backgroundColor: Colors.black,
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
                          color: Colors.white,
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
                      backgroundColor: Colors.black,
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
                          color: Colors.white,
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
