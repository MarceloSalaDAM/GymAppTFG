import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_app_tfg/src/views/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onLanguageChanged;

  CustomDrawer({required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0XFF0f7991),
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage('assets/image.png'),
                  fit: BoxFit.cover, // Ajusta según tus necesidades
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.white),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildDrawerItem('Cambiar Idioma', Icons.language, () {
                    Navigator.pop(context);
                    _showLanguageDialog(context);
                  }),
                  Divider(color: Colors.white),
                  buildDrawerItem('Cerrar Sesión', Icons.exit_to_app, () {
                    Navigator.pop(context);
                    _showSignOutConfirmation(context);
                  }),
                  Divider(color: Colors.white),
                  buildDrawerItem('Ayuda', Icons.help, () {
                    Navigator.pop(context);
                    _showInfoDialog(context);
                  }),
                ],
              ),
            ),
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
                onLanguageChanged(
                    'Español'); // Cambia 'Español' por el idioma seleccionado
                Navigator.pop(context);
              },
              child: Text('Español'),
            ),
            TextButton(
              onPressed: () {
                onLanguageChanged(
                    'Inglés'); // Cambia 'Inglés' por el idioma seleccionado
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

  Future<void> _showInfoDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              'Sobre FLEXIFY'),
          content: SingleChildScrollView(
            child: Text('¡Bienvenido a Flexify!\n'
                'Gracias por elegir nuestra aplicación para acompañarte en tu viaje hacia un estilo de vida más saludable y activo.'
                '\nQueremos que aproveches al máximo todas las funciones que hemos desarrollado para ti.\n\n '
                '¿Cómo funciona la aplicación?\n'
                'Flexify está diseñada para proporcionarte una experiencia personalizada en tu entrenamiento físico.\n'
                'Explora la sección de ejercicios, sigue tu progreso y ajusta tu perfil en la sección de configuración.\n\n'
                '¿Necesitas ayuda o tienes preguntas?\n'
                'Estamos aquí para ayudarte en cada paso del camino. Si tienes alguna pregunta, inquietud o simplemente necesitas orientación,\n'
                'no dudes en consultarnos a traves de e-mail: flexify.support@gmail.com'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('SALIR'),
            ), // Agrega más opciones según sea necesario
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

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginViewApp()),
                      (route) => false,
                );
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

}
