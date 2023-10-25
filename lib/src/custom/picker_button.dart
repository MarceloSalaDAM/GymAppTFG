import 'package:flutter/material.dart';

class PickerButton<T> extends StatelessWidget {
  final String titulo;
  final List<T> opciones;
  final T valorSeleccionado;
  final void Function(T?)? onChanged;

  PickerButton({
    required this.titulo,
    required this.opciones,
    required this.valorSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.bold, // Texto en negrita
          fontSize: 18.0, // Tamaño de fuente personalizado
        ),
      ),
      trailing: DropdownButton<T>(
        value: valorSeleccionado,
        onChanged: onChanged,
        items: opciones.map((T option) {
          return DropdownMenuItem<T>(
            value: option,
            child: Text(option.toString()),
          );
        }).toList(),
      ),
    );
  }
}
