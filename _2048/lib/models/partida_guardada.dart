class PartidaGuardada {
  final int? id;
  final int usuarioId;
  final String tablero;
  final int puntuacion;
  final int movimientos;
  final int segundosTranscurridos;

  PartidaGuardada({
    this.id,
    required this.usuarioId,
    required this.tablero,
    required this.puntuacion,
    required this.movimientos,
    required this.segundosTranscurridos,
  });

  //convertimos la partida guardada en un mapa para sqflite
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'tablero': tablero,
      'puntuacion': puntuacion,
      'movimientos': movimientos,
      'segundos_transcurridos': segundosTranscurridos,
    };
  }

  //convertimos los datos de sqflite en un objeto partida guardada
  static PartidaGuardada fromMap(Map<String, Object?> mapa) {
    return PartidaGuardada(
      id: mapa['id'] as int?,
      usuarioId: mapa['usuario_id'] as int,
      tablero: mapa['tablero'] as String,
      puntuacion: mapa['puntuacion'] as int,
      movimientos: mapa['movimientos'] as int,
      segundosTranscurridos: mapa['segundos_transcurridos'] as int,
    );
  }
}
