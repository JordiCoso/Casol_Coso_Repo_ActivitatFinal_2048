import 'package:_2048/data/databasehelper.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';

class UsuarioDao {
  final Databasehelper _databasehelper;

  const UsuarioDao(this._databasehelper);

  Future<int> insertarUsuario(Usuario usuario) async {
    final int resultado = await _databasehelper.baseDeDatos.insert(
      Databasehelper.tablaUsuarios,
      usuario.toMap(),
    );
    return resultado;
  }

  //comprobamos si el email ya existe
  Future<bool> existeEmail(String email) async {
    final resultado = await _databasehelper.baseDeDatos.query(
      Databasehelper.tablaUsuarios,
      where: '${Databasehelper.columnaUsuariosEmail} = ?',
      whereArgs: [email],
    );

    return resultado.isNotEmpty;
  }

  //buscamos un usuario por su email
  Future<Usuario?> obtenerUsuarioPorEmail(String email) async {
    final resultado = await _databasehelper.baseDeDatos.query(
      Databasehelper.tablaUsuarios,
      where: '${Databasehelper.columnaUsuariosEmail} = ?',
      whereArgs: [email],
    );

    if (resultado.isNotEmpty) {
      return Usuario.fromMap(resultado[0]);
    }

    return null;
  }
}
