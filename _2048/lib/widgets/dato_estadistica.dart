import 'package:flutter/material.dart';

class DatoEstadistica extends StatelessWidget {
  final String titulo;
  final String valor;

  const DatoEstadistica({super.key, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(titulo), Text(valor)]);
  }
}
