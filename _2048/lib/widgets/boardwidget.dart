import 'dart:collection';
import 'dart:math';

import 'package:_2048/models/colores.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cuadrado.dart';
import '../models/tablero.dart';
import '../routes.dart';

class BoardWidget extends StatelessWidget {
  final List<Container> gridVisual;

  GestureDragEndCallback? onHorizontalDragEnd;
  GestureDragEndCallback? onVerticalDragEnd;

  BoardWidget({
    super.key,
    required this.gridVisual,
    required this.onHorizontalDragEnd,
    required this.onVerticalDragEnd,
  });

  final colores = obtenerEsquemaColoresActual(
    PreferenciasService.instanciaPS.obtenerTemaOscuro(),
  );

  late Color colorTablero = colores[NombreColores.superficie]!;

  late Color colorBorde = colores[NombreColores.bordes]!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: onHorizontalDragEnd,
      onVerticalDragEnd: onVerticalDragEnd,
      child: Container(
        decoration: BoxDecoration(
          color: colorTablero,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorBorde, width: 5),
        ),
        alignment: Alignment.center,
        height: 350,
        width: 350,
        child: Wrap(runSpacing: 5, spacing: 5, children: gridVisual),
      ),
    );
  }
}
