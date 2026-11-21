import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final String textoCancelar;
  final VoidCallback onConfirmar;
  final VoidCallback onCancelar;

  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    required this.textoConfirmar,
    required this.textoCancelar,
    required this.onConfirmar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: onCancelar, child: Text(textoCancelar)),
        TextButton(onPressed: onConfirmar, child: Text(textoConfirmar)),
      ],
    );
  }
}
