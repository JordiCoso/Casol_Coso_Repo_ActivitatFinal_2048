import 'package:flutter/material.dart';
import '/models/iconos.dart';

class Habito {
  late Icon icono;
  late int identificador;
  late String nombre;
  late String nombreUsuario;
  late Color color;
  late DateTime fechaCompletado;
  bool completado = false;
  bool pendingBorrarse = false;
  int rachaActual = 0;
  int diasCompletados = 0;

  Habito(
    this.identificador,
    this.nombre,
    this.color,
    this.fechaCompletado, {
    this.nombreUsuario = '',
  }) {
    icono = Icon(
      opcionesIconos[0],
      color: color,
    ); //cuando se crea un habito nuevo, se pone un icono por default
  }

  Habito.fromBBDD({
    required int iconoInt,
    required int hid,
    required String nombreHabito,
    required String colorString,
    required int completadoInt,
    required String fechaCompletadoString,
    required this.rachaActual,
    required this.diasCompletados,
    required this.nombreUsuario,
  }) {
    identificador = hid;
    nombre = nombreHabito;
    color = _convertirStringAColor(colorString);
    completado = completadoInt == 1;
    fechaCompletado = DateTime.parse(fechaCompletadoString);

    // Icono se enviara como un INTEGER
    switch (iconoInt) {
      case 0:
        icono = Icon(Icons.water_drop, color: color);
        break;
      case 1:
        icono = Icon(Icons.directions_run, color: color);
        break;
      case 2:
        icono = Icon(Icons.grass, color: color);
        break;
    }
  }

  Color _convertirStringAColor(String color) {
    List<String> argb = color.split('|');

    late final double a;
    late final double r;
    late final double g;
    late final double b;

    for (int i = 0; i < argb.length; i++) {
      switch (i) {
        case 0:
          a = double.parse(argb[i]);
          break;
        case 1:
          r = double.parse(argb[i]);
          break;
        case 2:
          g = double.parse(argb[i]);
          break;
        case 3:
          b = double.parse(argb[i]);
          break;

        default:
      }
    }

    return Color.from(alpha: a, red: r, green: g, blue: b);
  }

  String convertirColorAString(Color color) {
    final String a = color.a.toString();
    final String r = color.r.toString();
    final String g = color.g.toString();
    final String b = color.b.toString();
    return '$a|$r|$g|$b';
  }

  void actualizarRacha() {
    DateTime hoy = DateTime.now();

    //comprobamos si se ha completado hoy
    if (fechaCompletado.year == hoy.year &&
        fechaCompletado.month == hoy.month &&
        fechaCompletado.day == hoy.day) {
      return;
    }

    diasCompletados++;

    //creamos variable para la fecha de ayer para hacer la comprobacion
    DateTime ayer = DateTime(hoy.year, hoy.month, hoy.day - 1);

    //comprobamos tambien si se completó ayer
    if (fechaCompletado.year == ayer.year &&
        fechaCompletado.month == ayer.month &&
        fechaCompletado.day == ayer.day) {
      rachaActual++;
    } else {
      rachaActual =
          1; //si no se completó el dia anterior se crea una racha nueva.
    }

    fechaCompletado = hoy; //actualizamos para que quede la ultima fecha.
  }

  int obtenerRacha() {
    DateTime hoy = DateTime.now();
    DateTime ayer = DateTime(hoy.year, hoy.month, hoy.day - 1);

    if ((fechaCompletado.year == hoy.year &&
            fechaCompletado.month == hoy.month &&
            fechaCompletado.day == hoy.day) ||
        (fechaCompletado.year == ayer.year &&
            fechaCompletado.month == ayer.month &&
            fechaCompletado.day == ayer.day)) {
      return rachaActual;
    }
    return 0; //si han pasado mas dias, la racha vuelve a 0.
  }
}
