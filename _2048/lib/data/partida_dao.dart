import 'package:sqflite/sqflite.dart';

import '../models/partida.dart';
import 'databasehelper.dart';

class PartidaDao {
  static const totalPartidas = 'total_partidas';
  static const mejorPuntuacion = 'mejor_puntuacion';
  static const mejorFicha = 'mejor_ficha';
  static const puntuacionMedia = 'puntuacion_media';
  static const tiempoTotalJugado = 'tiempo_total_jugado';

  Database get _db => DatabaseHelper.instanciaDH.baseDeDatos;

  //guardamos una partida terminada en la bbdd
  Future<int> insertarPartida(Partida partida) async {
    final int resultado = await _db.insert(
      DatabaseHelper.tablaPartidas,
      partida.toMap(),
    );

    return resultado;
  }

  //pillamos las partidas terminadas de un usuario
  Future<List<Partida>> obtenerPartidasUsuario(String nombreUsuario) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      where: '${DatabaseHelper.columnaPartidasUsuario} = ?',
      whereArgs: [nombreUsuario],
      orderBy: '${DatabaseHelper.columnaPartidasFecha} DESC',
    );

    //convertimos los registros de sqflite en objetos partida
    List<Partida> partidas = [];

    for (final mapa in resultado) {
      partidas.add(Partida.fromMap(mapa));
    }

    return partidas;
  }

  Future<Partida?> obtenerPartidaPorId(int id) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      where: '${DatabaseHelper.columnaPartidasId} = ?',
      whereArgs: [id],
    );

    if (resultado.isNotEmpty) {
      return Partida.fromMap(resultado[0]);
    }

    return null;
  }

  //eliminamos una partida por su id
  Future<int> eliminarPartida(int id) async {
    final int resultado = await _db.delete(
      DatabaseHelper.tablaPartidas,
      where: '${DatabaseHelper.columnaPartidasId} = ?',
      whereArgs: [id],
    );

    return resultado;
  }

  //eliminamos todas las partidas terminadas
  Future<int> eliminarHistorial() async {
    final int resultado = await _db.delete(DatabaseHelper.tablaPartidas);

    return resultado;
  }

  //pillamos las 10 partidas con mayor puntuacion
  Future<List<Partida>> obtenerRanking() async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      orderBy: '${DatabaseHelper.columnaPartidasPuntuacion} DESC',
      limit: 10,
    );

    //convertimos los registros de sqflite en objetos partida
    List<Partida> partidas = [];

    for (final mapa in resultado) {
      partidas.add(Partida.fromMap(mapa));
    }

    return partidas;
  }

  //obtenemos las estadisticas de las partidas de un usuario
  Future<Map<String, Object?>> obtenerEstadisticasUsuario(
    String nombreUsuario,
  ) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      columns: [
        'COUNT(*) AS $totalPartidas',
        'MAX(${DatabaseHelper.columnaPartidasPuntuacion}) AS $mejorPuntuacion',
        'MAX(${DatabaseHelper.columnaPartidasFichamaxima}) AS $mejorFicha',
      ],
      where: '${DatabaseHelper.columnaPartidasUsuario} = ?',
      whereArgs: [nombreUsuario],
    );
    return resultado[0];
  }

  //pillamos las partidas filtradas por usuario y ficha maxima
  Future<List<Partida>> obtenerPartidasFiltradas(
    String nombreUsuario,
    int fichaMaxima,
  ) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      where:
          '${DatabaseHelper.columnaPartidasUsuario} = ? AND '
          '${DatabaseHelper.columnaPartidasFichamaxima} >= ?',
      whereArgs: [nombreUsuario, fichaMaxima],
      orderBy: '${DatabaseHelper.columnaPartidasFecha} DESC',
    );

    //convertimos los registros de sqlite en objetos partida
    List<Partida> partidas = [];

    for (final mapa in resultado) {
      partidas.add(Partida.fromMap(mapa));
    }

    return partidas;
  }

  //todas las partidas ordenadas por fecha
  Future<List<Partida>> obtenerTodasLasPartidas() async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      orderBy: '${DatabaseHelper.columnaPartidasFecha} DESC',
    );

    //convertimos los registros de sqflite en objetos partida
    List<Partida> partidas = [];

    for (final mapa in resultado) {
      partidas.add(Partida.fromMap(mapa));
    }

    return partidas;
  }

  //buscamos las partidas que alcanzaron una ficha maxima concreta
  Future<List<Partida>> obtenerPartidasPorFicha(int fichaMaxima) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      where: '${DatabaseHelper.columnaPartidasFichamaxima} >= ?',
      whereArgs: [fichaMaxima],
      orderBy: '${DatabaseHelper.columnaPartidasFecha} DESC',
    );

    //convertimos los registros de sqlite en objetos partida
    List<Partida> partidas = [];

    for (final mapa in resultado) {
      partidas.add(Partida.fromMap(mapa));
    }

    return partidas;
  }

  Future<Map<String, Object?>> obtenerEstadisticasGlobales() async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      columns: [
        'COUNT(*) AS $totalPartidas',
        'MAX(${DatabaseHelper.columnaPartidasPuntuacion}) AS $mejorPuntuacion',
        'AVG(${DatabaseHelper.columnaPartidasPuntuacion}) AS $puntuacionMedia',
        'MAX(${DatabaseHelper.columnaPartidasFichamaxima}) AS $mejorFicha',
        'SUM(${DatabaseHelper.columnaPartidasDuracionsegundos}) AS $tiempoTotalJugado',
      ],
    );

    return resultado[0];
  }

  //obtenemos las estadisticas por jugador
  Future<List<Map<String, Object?>>> obtenerEstadisticasPorJugador() async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      columns: [
        DatabaseHelper.columnaPartidasUsuario,
        'COUNT(*) AS $totalPartidas',
        'MAX(${DatabaseHelper.columnaPartidasPuntuacion}) AS $mejorPuntuacion',
      ],
      groupBy: DatabaseHelper.columnaPartidasUsuario,
      orderBy: '$mejorPuntuacion DESC',
    );

    return resultado;
  }

  //guardamos la partida terminada y eliminamos la partida pendiente
  Future<void> finalizarPartida(Partida partida) async {
    await _db.transaction((txn) async {
      await txn.insert(DatabaseHelper.tablaPartidas, {
        DatabaseHelper.columnaPartidasUsuario: partida.usuario,
        DatabaseHelper.columnaPartidasPuntuacion: partida.puntuacion,
        DatabaseHelper.columnaPartidasFichamaxima: partida.fichaMaxima,
        DatabaseHelper.columnaPartidasMovimientos: partida.movimientos,
        DatabaseHelper.columnaPartidasDuracionsegundos:
            partida.duracionSegundos,
        DatabaseHelper.columnaPartidasFecha: partida.fecha,
      });

      await txn.delete(
        DatabaseHelper.tablaGuardado,
        where: '${DatabaseHelper.columnaGuardadoId} = ?',
        whereArgs: [1],
      );
    });
  }

  //para restaurar una partida eliminada
  Future<void> restaurarPartida(Partida partida) async {
    await _db.insert(
      DatabaseHelper.tablaPartidas,
      partida.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
