import 'package:_2048/data/databasehelper.dart';
import 'package:sqflite/sqflite.dart';

import '../models/usuario.dart';

class UsuarioDao {
  Database get _db => DatabaseHelper.instanciaDH.baseDeDatos;

  Future<int> insertarUsuario(Usuario usuario) async {
    final int resultado = await _db.insert(
      DatabaseHelper.tablaUsuarios,
      usuario.toMap(),
    );
    return resultado;
  }

  //comprobamos si el email ya existe
  Future<bool> existeEmail(String email) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.columnaUsuariosEmail} = ?',
      whereArgs: [email],
    );

    return resultado.isNotEmpty;
  }

  //comprobamos si el nombre de usuario ya existe
  Future<bool> existeUsuario(String nombreUsuario) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.columnaUsuariosUsuario} = ?',
      whereArgs: [nombreUsuario],
    );

    return resultado.isNotEmpty;
  }

  //buscamos un usuario por su email
  Future<Usuario?> obtenerUsuarioPorEmail(String email) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.columnaUsuariosEmail} = ?',
      whereArgs: [email],
    );

    if (resultado.isNotEmpty) {
      return Usuario.fromMap(resultado[0]);
    }

    return null;
  }

  //buscamos un usuario por su nombre de usuario
  Future<Usuario?> obtenerUsuarioPorNombre(String nombreUsuario) async {
    final resultado = await _db.query(
      DatabaseHelper.tablaUsuarios,
      where: '${DatabaseHelper.columnaUsuariosUsuario} = ?',
      whereArgs: [nombreUsuario],
    );

    if (resultado.isNotEmpty) {
      return Usuario.fromMap(resultado[0]);
    }

    return null;
  }
}
