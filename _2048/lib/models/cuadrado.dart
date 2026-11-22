import 'package:_2048/models/colores.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:flutter/material.dart';

class Cuadrado {
  String posicion;
  bool combinado = false;
  final int valor;

  String get x {
    return posicion[1];
  }

  set x(String x) {
    String y = posicion[0];
    posicion = '$y$x';
  }

  String get y {
    return posicion[0];
  }

  set y(String y) {
    String x = posicion[1];
    posicion = '$y$x';
  }

  Cuadrado.vacio() : valor = 0, posicion = '00';

  Cuadrado({required this.posicion, required this.valor});

  void mover(String posicionNueva) {
    posicion = posicionNueva;
  }

  Container toContainer() {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(),
    );
    return Container(
      color: colores['$valor'],
      width: 80,
      height: 80,
      child: Center(child: Text('$valor')),
    );
  }
}
