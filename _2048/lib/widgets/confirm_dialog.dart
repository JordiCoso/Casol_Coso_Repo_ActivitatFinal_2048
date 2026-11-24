import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final String textoCancelar;
  final VoidCallback onConfirmar;
  final VoidCallback onCancelar;
  final String? textoAdicional;
  final VoidCallback? onAdicional;

  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    required this.textoConfirmar,
    required this.textoCancelar,
    required this.onConfirmar,
    required this.onCancelar,
    this.textoAdicional,
    this.onAdicional,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: onCancelar, child: Text(textoCancelar)),
        if (textoAdicional != null && onAdicional != null)
          TextButton(onPressed: onAdicional, child: Text(textoAdicional!)),
        TextButton(onPressed: onConfirmar, child: Text(textoConfirmar)),
      ],
    );
  }
}
