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
  Future<List<Partida>> obtenerPartidasUsuario(int usuarioId) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      where: '${DatabaseHelper.columnaPartidasUsuarioId} = ?',
      whereArgs: [usuarioId],
      orderBy: '${DatabaseHelper.columnaPartidasFecha} DESC',
    );

    //convertimos los registros de sqflite en objetos partida
    List<Partida> partidas = [];

    for (final mapa in resultado) {
      //pillamos el nombre del usuario por su id
      final resultadoUsuario = await _db.query(
        DatabaseHelper.tablaUsuarios,
        where: '${DatabaseHelper.columnaUsuariosId} = ?',
        whereArgs: [mapa['usuario_id']],
      );

      //añadimos el nombre al mapa de la partida
      Map<String, Object?> datosPartida = Map<String, Object?>.from(mapa);

      datosPartida['usuario'] =
          resultadoUsuario[0][DatabaseHelper.columnaUsuariosUsuario];

      //convertimos el mapa en un objeto partida
      partidas.add(Partida.fromMap(datosPartida));
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
      //pillamos el nombre del usuario por su id
      final resultadoUsuario = await _db.query(
        DatabaseHelper.tablaUsuarios,
        where: '${DatabaseHelper.columnaUsuariosId} = ?',
        whereArgs: [resultado[0]['usuario_id']],
      );

      //añadimos el nombre al mapa de la partida
      Map<String, Object?> datosPartida = Map<String, Object?>.from(
        resultado[0],
      );

      datosPartida['usuario'] =
          resultadoUsuario[0][DatabaseHelper.columnaUsuariosUsuario];

      return Partida.fromMap(datosPartida);
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
      //pillamos el nombre del usuario por su id
      final resultadoUsuario = await _db.query(
        DatabaseHelper.tablaUsuarios,
        where: '${DatabaseHelper.columnaUsuariosId} = ?',
        whereArgs: [mapa['usuario_id']],
      );

      //añadimos el nombre al mapa de la partida
      Map<String, Object?> datosPartida = Map<String, Object?>.from(mapa);

      datosPartida['usuario'] =
          resultadoUsuario[0][DatabaseHelper.columnaUsuariosUsuario];

      partidas.add(Partida.fromMap(datosPartida));
    }

    return partidas;
  }

  //obtenemos las estadisticas de las partidas de un usuario
  Future<Map<String, Object?>> obtenerEstadisticasUsuario(int usuarioId) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      columns: [
        'COUNT(*) AS $totalPartidas',
        'MAX(${DatabaseHelper.columnaPartidasPuntuacion}) AS $mejorPuntuacion',
        'MAX(${DatabaseHelper.columnaPartidasFichamaxima}) AS $mejorFicha',
      ],
      where: '${DatabaseHelper.columnaPartidasUsuarioId} = ?',
      whereArgs: [usuarioId],
    );
    return resultado[0];
  }

  //pillamos las partidas filtradas por usuario y ficha maxima
  Future<List<Partida>> obtenerPartidasFiltradas(
    int usuarioId,
    int fichaMaxima,
  ) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaPartidas,
      where:
          '${DatabaseHelper.columnaPartidasUsuarioId} = ? AND '
          '${DatabaseHelper.columnaPartidasFichamaxima} >= ?',
      whereArgs: [usuarioId, fichaMaxima],
      orderBy: '${DatabaseHelper.columnaPartidasFecha} DESC',
    );

    //convertimos los registros de sqlite en objetos partida
    List<Partida> partidas = [];

    for (final mapa in resultado) {
      //pillamos el nombre de usuario por su id
      final resultadoUsuario = await _db.query(
        DatabaseHelper.tablaUsuarios,
        where: '${DatabaseHelper.columnaUsuariosId} = ?',
        whereArgs: [mapa['usuario_id']],
      );

      //añadimos el nombre al mapa de la partida
      Map<String, Object?> datosPartida = Map<String, Object?>.from(mapa);

      datosPartida['usuario'] =
          resultadoUsuario[0][DatabaseHelper.columnaUsuariosUsuario];

      partidas.add(Partida.fromMap(datosPartida));
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
      //pillamos el nombre de usuario por su id
      final resultadoUsuario = await _db.query(
        DatabaseHelper.tablaUsuarios,
        where: '${DatabaseHelper.columnaUsuariosId} = ?',
        whereArgs: [mapa['usuario_id']],
      );

      Map<String, Object?> datosPartida = Map<String, Object?>.from(mapa);

      datosPartida['usuario'] =
          resultadoUsuario[0][DatabaseHelper.columnaUsuariosUsuario];

      partidas.add(Partida.fromMap(datosPartida));
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
      final resultadoUsuario = await _db.query(
        DatabaseHelper.tablaUsuarios,
        where: '${DatabaseHelper.columnaUsuariosId} = ?',
        whereArgs: [mapa['usuario_id']],
      );

      Map<String, Object?> datosPartida = Map<String, Object?>.from(mapa);

      datosPartida['usuario'] =
          resultadoUsuario[0][DatabaseHelper.columnaUsuariosUsuario];

      partidas.add(Partida.fromMap(datosPartida));
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
        DatabaseHelper.columnaPartidasUsuarioId,
        'COUNT(*) AS $totalPartidas',
        'MAX(${DatabaseHelper.columnaPartidasPuntuacion}) AS $mejorPuntuacion',
      ],
      groupBy: DatabaseHelper.columnaPartidasUsuarioId,
      orderBy: '$mejorPuntuacion DESC',
    );

    List<Map<String, Object?>> estadisticas = [];

    for (final mapa in resultado) {
      final resultadoUsuario = await _db.query(
        DatabaseHelper.tablaUsuarios,
        where: '${DatabaseHelper.columnaUsuariosId} = ?',
        whereArgs: [mapa['usuario_id']],
      );

      Map<String, Object?> datosJugador = Map<String, Object?>.from(mapa);

      datosJugador['usuario'] =
          resultadoUsuario[0][DatabaseHelper.columnaUsuariosUsuario];

      estadisticas.add(datosJugador);
    }

    return estadisticas;
  }

  //guardamos la partida terminada y eliminamos la partida pendiente
  Future<void> finalizarPartida(Partida partida) async {
    await _db.transaction((txn) async {
      await txn.insert(DatabaseHelper.tablaPartidas, {
        DatabaseHelper.columnaPartidasUsuarioId: partida.usuarioId,
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
