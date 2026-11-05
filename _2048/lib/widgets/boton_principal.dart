import 'package:flutter/material.dart';

class BotonPrincipal extends StatelessWidget {
  //recibimos el texto q tendrá el botón y la función que queremos cuando el usuario pulse el boton
  final String texto;
  final VoidCallback pulsar;

  const BotonPrincipal ({super.key, required this.texto, required this.pulsar});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
      ),
      onPressed: pulsar,
      child: Text(
        texto,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}