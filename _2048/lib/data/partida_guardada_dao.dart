import 'package:_2048/data/databasehelper.dart';
import 'package:sqflite/sqflite.dart';

import '../models/partida_guardada.dart';

class PartidaGuardadaDao {
  Database get _db => DatabaseHelper.instanciaDH.baseDeDatos;

  //guardamos la partida y sustituimos la anterior si existe
  Future<int> guardarPartida(PartidaGuardada partida) async {
    final int resultado = await _db.insert(DatabaseHelper.tablaGuardado, {
      DatabaseHelper.columnaGuardadoId: 1,
      DatabaseHelper.columnaGuardadoUsuarioId: partida.usuarioId,
      DatabaseHelper.columnaGuardadoTablero: partida.tablero,
      DatabaseHelper.columnaGuardadoPuntuacion: partida.puntuacion,
      DatabaseHelper.columnaGuardadoMovimientos: partida.movimientos,
      DatabaseHelper.columnaGuardadoSegundostranscurridos:
          partida.segundosTranscurridos,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return resultado;
  }

  //obtenemos la partida guardada del usuario si existe
  Future<PartidaGuardada?> obtenerPartidaGuardada(int usuarioId) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaGuardado,
      where: 'id = ? AND usuario_id = ?',
      whereArgs: [1, usuarioId],
    );

    if (resultado.isNotEmpty) {
      return PartidaGuardada.fromMap(resultado[0]);
    }

    return null;
  }

  Future<int> eliminarPartidaGuardada(int usuarioId) async {
    final int resultado = await _db.delete(
      DatabaseHelper.tablaGuardado,
      where: 'id = ? AND usuario_id = ?',
      whereArgs: [1, usuarioId],
    );

    return resultado;
  }
}
