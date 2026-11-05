import 'package:flutter/material.dart';

//se puede reutilizar para usuario, nombre, correo y contraseña. y ocultarTexto es flase por default pq no todos los campos son contraseñas
class CampoTextoApp extends StatelessWidget {
  final String etiqueta; //para mostrar el nomnbre y el usuario...
  final TextEditingController controller; //para leer el texto.
  final bool? enabled;
  final VoidCallback? onEditingComplete;
  final bool ocultarTexto; //para ocultar la contraseña.
  final Color? color;

  const CampoTextoApp({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.enabled,
    this.onEditingComplete,
    this.ocultarTexto = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      //conecta con el TextEditingController.
      enabled: enabled,
      onEditingComplete: onEditingComplete,
      obscureText: ocultarTexto,
      //cuando sea true, se ocultará el texto.
      //muestra la etiqueta que le damos y dibuja un borde alrededor.
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
      ),
      style: color == null ? null : TextStyle(color: color),
    );
  }
}
