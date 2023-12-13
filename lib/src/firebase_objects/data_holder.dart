import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app_tfg/src/firebase_objects/ejercicios_firebase.dart';
import 'package:gym_app_tfg/src/firebase_objects/usuarios_firebase.dart';

import 'fb_admin.dart';

class DataHolderExamen {
/*  El DATAHOLDER nos sirve para la descarga del perfil y
  los elementos del dicho perfil*/

  static final DataHolderExamen _dataHolderExamen =
      new DataHolderExamen._internal();

  String sCOLLECTIONS_BICHOS_NAME = "bichos";

  String sMensaje = "";
  Usuarios usuario = Usuarios();

  Ejercicios ejercicios = Ejercicios(musculos: [], uid: '');
  FbAdmin fbAdmin = FbAdmin();

  DataHolderExamen._internal() {
    sMensaje = "HOLA";
  }

  factory DataHolderExamen() {
    return _dataHolderExamen;
  }

  Future<void> descargarMIPerfil() async {
    usuario = await fbAdmin
        .descargarPerfil(FirebaseAuth.instance.currentUser?.uid) as Usuarios;
  }

  Future<void> descargarPerfilGenerico(String? idPerfil) async {
    await fbAdmin.descargarPerfil(idPerfil) as Usuarios;
  }

  bool isMIPerfilDownloaded() {
    return usuario != null;
  }
}
