import 'package:flutter/material.dart';

class IPLogin extends StatefulWidget {
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
  _IPLoginState createState() => _IPLoginState();
}

class _IPLoginState extends State<IPLogin> {
  bool _obscureText = true; // Establecemos el estado inicial como oculto

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.contra && _obscureText,
      controller: widget.myController,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        helperText: widget.textoGuia,
        labelText: widget.titulo,
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(7.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(7.0),
        ),
        suffixIcon: widget.contra
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off
                      : Icons.visibility, // Cambiamos los íconos
                  color: Colors.grey.shade600, // Cambia el color del ícono
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
