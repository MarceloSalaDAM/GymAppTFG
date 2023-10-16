import 'package:flutter/material.dart';

class IPApp extends StatelessWidget {
  final String titulo;
  final String textoGuia;
  final TextEditingController myController = TextEditingController(text: "");

  IPApp({
    Key? key,
    this.titulo = " ",
    this.textoGuia = " ",
  }) : super(key: key);

  String getText() {
    return myController.text;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: myController,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        helperText: textoGuia,
        labelText: titulo,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 10,

        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),

          borderRadius:
          BorderRadius.circular(7.0), // Cambia el color del borde a rojo
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius:
          BorderRadius.circular(7.0), // Cambia el color del borde a rojo
        ),
      ),
    );
  }
}
