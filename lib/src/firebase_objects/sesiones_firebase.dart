class Sesion {
  final String duracion;
  final DateTime fecha;

  Sesion({
    required this.duracion,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'duracion': duracion,
      'fecha': fecha,
    };
  }
}
