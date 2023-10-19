import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SettingsView extends StatefulWidget {
  SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String _selectedLanguage = 'Español'; // Idioma predeterminado

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedLanguage = prefs.getString('selectedLanguage');
    if (selectedLanguage != null) {
      setState(() {
        _selectedLanguage = selectedLanguage;
      });
    }
  }

  Future<void> _changeLanguage(String newLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', newLanguage);
    setState(() {
      _selectedLanguage = newLanguage;
    });
  }

  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popAndPushNamed('/Login');
    print("USUARIO CERRADO");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: double.maxFinite,
            height: double.maxFinite,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/fondo.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(50, 150, 50, 60),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                width: 500,
                height: 450,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 5.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'AJUSTES',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.overline,
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButton<String>(
                          value: _selectedLanguage,
                          items: <String>[
                            'Español',
                            'Inglés',
                            'Francés',
                            'Alemán'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _changeLanguage(newValue);
                              // Cambiar el idioma de la aplicación según la selección del usuario
                              // Puedes utilizar la biblioteca intl para la internacionalización.
                              // Aquí puedes establecer el nuevo locale según el idioma seleccionado.
                              Locale newLocale =
                                  _getLocaleForLanguage(newValue);
                              // Luego, configura el nuevo locale en la aplicación
                              // Esto es solo un ejemplo, y debes configurar la internacionalización en tu aplicación.
                              //intl.updateLocales(newLocale);

                              // Otras tareas necesarias para cambiar el idioma de la aplicación.
                            }
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            signOut(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          child: const Text('Cerrar Sesión',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Locale _getLocaleForLanguage(String language) {
    switch (language) {
      case 'Español':
        return Locale('es', 'ES');
      case 'Inglés':
        return Locale('en', 'US');
      case 'Francés':
        return Locale('fr', 'FR');
      case 'Alemán':
        return Locale('de', 'DE');
      default:
        return Locale('es', 'ES'); // Idioma predeterminado
    }
  }
}
