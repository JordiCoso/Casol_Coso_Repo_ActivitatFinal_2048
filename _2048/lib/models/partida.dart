class Partida {
  final int? id;
  final int usuarioId;
  final String usuario;
  final int puntuacion;
  final int fichaMaxima;
  final int movimientos;
  final int duracionSegundos;
  final String fecha;

  Partida({
    this.id,
    required this.usuarioId,
    required this.usuario,
    required this.puntuacion,
    required this.fichaMaxima,
    required this.movimientos,
    required this.duracionSegundos,
    required this.fecha,
  });

  //convertimos la partida en un mapa para guardarla en sqflite
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'usuario': usuario,
      'puntuacion': puntuacion,
      'ficha_maxima': fichaMaxima,
      'movimientos': movimientos,
      'duracion_segundos': duracionSegundos,
      'fecha': fecha,
    };
  }

  //convertimos los datos de sqlite en un objeto partida
  static Partida fromMap(Map<String, Object?> mapa) {
    return Partida(
      id: mapa['id'] as int?,
      usuarioId: mapa['usuario_id'] as int,
      usuario: mapa['usuario'] as String,
      puntuacion: mapa['puntuacion'] as int,
      fichaMaxima: mapa['ficha_maxima'] as int,
      movimientos: mapa['movimientos'] as int,
      duracionSegundos: mapa['duracion_segundos'] as int,
      fecha: mapa['fecha'] as String,
    );
  }
}
