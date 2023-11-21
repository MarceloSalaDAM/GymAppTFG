import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsMenu {
  static Future<void> showSignOutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popAndPushNamed('/Login');
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  static Widget buildDrawer(BuildContext context, Function(String) onSelected) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              'Configuración',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Cerrar Sesión'),
            onTap: () {
              Navigator.pop(context);
              onSelected('signout');
            },
          ),
        ],
      ),
    );
  }
}
