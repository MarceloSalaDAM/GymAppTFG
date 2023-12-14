import 'package:flutter/material.dart';
import 'alert_dialogs.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onLanguageChanged;

  const CustomDrawer({super.key, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0XFF0f7991),
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: AssetImage('assets/image.png'),
                  fit: BoxFit.cover, // Ajusta según tus necesidades
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildDrawerItem('Cambiar Idioma', Icons.language, () async {
                    Navigator.pop(context);
                    await AlertDialogManager.showLanguageDialog(context);
                  }),
                  const Divider(color: Colors.white),
                  buildDrawerItem('Ayuda', Icons.help, () async {
                    Navigator.pop(context);
                    await AlertDialogManager.showInfoDialog(context);
                  }),
                ],
              ),
            ),
            const Divider(color: Colors.white),
            buildDrawerItem('Cerrar Sesión', Icons.exit_to_app, () async {
              Navigator.pop(context);
              await AlertDialogManager.showSignOutConfirmation(context);
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      onTap: onTap,
    );
  }
}
