import 'package:flutter/material.dart';
import '../firebase_objects/objetivos_firebase.dart'; // Asegúrate de importar la clase Objetivos desde su ubicación correcta

class ObjetivosGeneralesScreen extends StatefulWidget {
  @override
  _ObjetivosGeneralesScreenState createState() =>
      _ObjetivosGeneralesScreenState();
}

class _ObjetivosGeneralesScreenState extends State<ObjetivosGeneralesScreen> {
  late Future<List<Objetivos>> _objetivosFuture;

  @override
  void initState() {
    super.initState();
    _objetivosFuture = Objetivos.getEjerciciosFromFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0XFF0f7991),
        title: Text(
          'OBJETIVOS',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Objetivos>>(
        future: _objetivosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final objetivo = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(objetivo.titulo),
                    subtitle: Text(objetivo.descripcion ?? ''),
                    leading: objetivo.imagen != null
                        ? Image.network(
                      objetivo.imagen!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                        : SizedBox.shrink(),
                    // Puedes personalizar esta tarjeta según tus necesidades
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No hay datos disponibles'));
          }
        },
      ),
    );
  }
}
