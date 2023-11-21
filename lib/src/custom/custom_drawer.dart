import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onLanguageChanged;

  CustomDrawer({required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildDrawerItem('Cambiar Idioma', Icons.language, () {
              Navigator.pop(context); // Cierra el Drawer
              _showLanguageDialog(context);
            }),
            Divider(color: Colors.white),
            buildDrawerItem('Cerrar Sesión', Icons.exit_to_app, () {
              Navigator.pop(context); // Cierra el Drawer
              _showSignOutConfirmation(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      onTap: onTap,
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar Idioma'),
          content: Text('Selecciona un nuevo idioma:'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                onLanguageChanged('Español'); // Cambia 'Español' por el idioma seleccionado
                Navigator.pop(context);
              },
              child: Text('Español'),
            ),
            TextButton(
              onPressed: () {
                onLanguageChanged('Inglés'); // Cambia 'Inglés' por el idioma seleccionado
                Navigator.pop(context);
              },
              child: Text('Inglés'),
            ),
            // Agrega más opciones según sea necesario
          ],
        );
      },
    );
  }

  Future<void> _showSignOutConfirmation(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.popAndPushNamed(context, '/Login');
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
