import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_app_tfg/src/firebase_objects/usuarios_firebase.dart';

class FbAdmin {

  FbAdmin();

  Future<Usuarios?> descargarPerfil(String? idPerfil) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final docRef = db.collection("usuarios").doc(idPerfil).withConverter(
        fromFirestore: Usuarios.fromFirestore,
        toFirestore: (Usuarios usuario, _) => usuario.toFirestore());

    final docSnap = await docRef.get();
    return docSnap.data();
  }
}
