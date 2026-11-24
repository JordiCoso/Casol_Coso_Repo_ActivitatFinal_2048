import 'package:_2048/models/colores.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:flutter/material.dart';

class Cuadrado {
  String posicion;
  late int x = int.parse(posicion[1]);
  late int y = int.parse(posicion[0]);
  bool combinado = false;
  bool nuevo;
  late final int valor;

  String get keyX {
    return posicion[1];
  }

  set keyX(String keyX) {
    String y = posicion[0];
    posicion = '$y$keyX';
    x = int.parse(keyX);
  }

  String get keyY {
    return posicion[0];
  }

  set keyY(String keyY) {
    String x = posicion[1];
    posicion = '$keyY$x';
    y = int.parse(keyY);
  }

  Cuadrado.vacio() : valor = 0, posicion = '00', nuevo = false;

  Cuadrado({required this.posicion, required this.valor, this.nuevo = false});

  Cuadrado.fromMap(Map<String, Object?> mapa)
    : this.posicion = mapa['posicion'] as String,
      valor = mapa['valor'] as int,
      this.nuevo = false;

  Map<String, Object?> toMap() {
    return {'posicion': posicion, 'valor': valor};
  }
}
