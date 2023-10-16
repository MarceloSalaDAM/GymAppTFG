import 'package:flutter/material.dart';

class IPLogin extends StatelessWidget {
  final String titulo;
  final String textoGuia;

  final bool contra;
  final TextEditingController myController = TextEditingController(text: "");

  IPLogin({
    Key? key,
    this.titulo = " ",
    this.textoGuia = " ",
    this.contra = false,
  }) : super(key: key);

  String getText() {
    return myController.text;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: contra,
      controller: myController,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        helperText: textoGuia,
        labelText: titulo,
        labelStyle: TextStyle(
          color: Colors.white,
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
