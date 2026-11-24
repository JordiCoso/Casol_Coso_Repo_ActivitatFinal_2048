import 'package:_2048/models/colores.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:flutter/material.dart';

class Cuadrado {
  String posicion;
  late int x = int.parse(posicion[1]);
  late int y = int.parse(posicion[0]);
  bool combinado = false;
  final int valor;

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

  Cuadrado.vacio() : valor = 0, posicion = '00';

  Cuadrado({required this.posicion, required this.valor});

  void mover(String posicionNueva) {
    posicion = posicionNueva;
  }

  Container toContainer(BuildContext context) {
    final bool temaOscuro = PreferenciasService.instanciaPS.obtenerTemaOscuro();
    final colorCuadrado =
        obtenerEsquemaColoresActual(temaOscuro)['$valor'] ??
        obtenerEsquemaColoresActual(temaOscuro)[NombreColores.bordes];
    final numeroClaro = obtenerEsquemaColoresActual(
      true,
    )[NombreColores.textoPrincipal]!;
    final numeroOscuro = obtenerEsquemaColoresActual(
      false,
    )[NombreColores.textoPrincipal]!;

    final Color colorTexto = (temaOscuro)
        ? (valor == 2)
              ? numeroClaro
              : numeroOscuro
        : (valor == 2)
        ? numeroOscuro
        : numeroClaro;
    return Container(
      decoration: BoxDecoration(
        color: colorCuadrado,
        borderRadius: BorderRadius.circular(12),
      ),

      width: 80,
      height: 80,
      child: Center(
        child: Text(
          '${(valor != 0) ? valor : ''}',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: colorTexto),
        ),
      ),
    );
  }
}
