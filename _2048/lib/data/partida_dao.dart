import 'package:sqflite/sqflite.dart';

import '../models/partida.dart';
import 'databasehelper.dart';

class PartidaDao {
  static const totalPartidas = 'total_partidas';
  static const mejorPuntuacion = 'mejor_puntuacion';
  static const mejorFicha = 'mejor_ficha';

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
}
