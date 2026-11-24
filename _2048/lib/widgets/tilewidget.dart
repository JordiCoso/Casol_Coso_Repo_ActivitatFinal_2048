import 'package:flutter/material.dart';

import '../models/colores.dart';
import '../services/preferenciasservice.dart';

class TileWidget extends StatelessWidget {
  final int valor;
  final double escala;
  final VoidCallback funcEscalar;
  final bool nuevo;

  const TileWidget({
    required this.valor,
    required this.escala,
    required this.funcEscalar,
    required this.nuevo
  });

  @override
  Widget build(BuildContext context) {
    final bool temaOscuro = PreferenciasService.instanciaPS.obtenerTemaOscuro(
      context,
    );
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

    if (!nuevo) {
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
            style: Theme
                .of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: colorTexto),
          ),
        ),
      );
    } else {
      return AnimatedScale(
        scale: escala,
        onEnd: funcEscalar,
        duration: const Duration(milliseconds: 400),
        child: Container(
          decoration: BoxDecoration(
            color: colorCuadrado,
            borderRadius: BorderRadius.circular(12),
          ),

          width: 80,
          height: 80,
          child: Center(
            child: Text(
              '${(valor != 0) ? valor : ''}',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: colorTexto),
            ),
          ),
        ),
      );
    }
  }
}
