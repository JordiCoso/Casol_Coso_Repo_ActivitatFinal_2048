import 'dart:collection';
import 'dart:convert';

import 'cuadrado.dart';

class Tablero {
  late final int tamanoTablero;
  late final Map<String, Cuadrado> tableroVacio;
  late Map<String, Cuadrado> tablero;

  Tablero({this.tamanoTablero = 4}) {
    tableroVacio = {};

    loopLineasYColumnas(
      tamanoTablero,
      ({required columna, required linea}) =>
          tableroVacio['$linea$columna'] = Cuadrado.vacio(),
    );

    tablero = tableroVacio;
  }

  Tablero.fromJson(String json) {
    final Map<String, Object?> jsonMap = jsonDecode(json);

    tamanoTablero = jsonMap['tamanoTablero'] as int? ?? 4;

    loopLineasYColumnas(
      tamanoTablero,
      ({required columna, required linea}) =>
          tablero['$linea$columna'] = jsonMap['$linea$columna'] as Cuadrado,
    );
  }

  String toJson(LinkedHashMap<String, Cuadrado> tableroGuardar) {
    tablero = tableroGuardar;
    return jsonEncode(tablero);
  }

  /// Para no repetir codigo de pasar por todas las linea/columna,
  /// he hecho una funcion la cual le puedes pasar la funcion que
  /// quieres que utilize este bucle y con las variables.
  void loopLineasYColumnas(
    int tamanoTablero,
    Function({required int linea, required int columna}) funcionAEjecutar,
  ) {
    for (int linea = 0; linea < tamanoTablero; linea++) {
      for (int columna = 0; columna < tamanoTablero; columna++) {
        funcionAEjecutar(linea: linea, columna: columna);
      }
    }
  }
}
