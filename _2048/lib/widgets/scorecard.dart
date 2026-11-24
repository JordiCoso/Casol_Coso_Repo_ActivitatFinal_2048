import 'package:flutter/material.dart';

class Scorecard extends StatelessWidget {
  final String etiqueta;
  final int valor;

  const Scorecard({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Text('$etiqueta : $valor');
  }
}
