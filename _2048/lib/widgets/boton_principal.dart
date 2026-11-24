import 'package:flutter/material.dart';

import '../models/colores.dart';
import '../services/preferenciasservice.dart';

class BotonPrincipal extends StatelessWidget {
  //recibimos el texto q tendrá el botón y la función que queremos cuando el usuario pulse el boton
  final String texto;
  final VoidCallback pulsar;

  const BotonPrincipal({super.key, required this.texto, required this.pulsar});

  @override
  Widget build(BuildContext context) {
    final bool temaOscuro = PreferenciasService.instanciaPS.obtenerTemaOscuro(context);

    final colores = obtenerEsquemaColoresActual(temaOscuro);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colores[NombreColores.principal],
        fixedSize: Size(300, 50),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: pulsar,
      child: Text(
        texto,
        style: TextStyle(
          color: temaOscuro
              ? colores[NombreColores.fondo]
              : colores[NombreColores.superficie],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
