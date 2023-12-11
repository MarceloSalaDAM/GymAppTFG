import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_objects/rutinas_firebase.dart';

class ListaRutinas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Rutinas'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .collection('rutinas')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // Obtener la lista de documentos desde el snapshot
          final List<DocumentSnapshot<Map<String, dynamic>>> documentos =
              snapshot.data!.docs;

          return ListView.builder(
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              // Convertir el documento en una instancia de Rutina
              final Rutina rutina = Rutina.fromFirestore(
                documentos[index],
                null, // Puedes pasar opciones de snapshot si es necesario
              );

              // Crear un widget para mostrar la rutina en la lista
              return ListTile(
                title: Text(rutina.nombre??'NOMBRE NO DISPONIBLE'),
                subtitle: Text(rutina.descripcion),
                // Aquí puedes agregar más información según tus necesidades
                // Ejemplo: Text('Días: ${rutina.dias.length}'),
              );
            },
          );
        },
      ),
    );
  }
}
