import 'package:flutter/material.dart';
import '/models/colores.dart';

import '../models/iconos.dart';

class TarjetaHabito extends StatelessWidget {
  final String nombre;
  final Color color;
  final bool completado;

  final Icon icono;

  final ValueChanged<bool?>? completar;
  final VoidCallback? editar;
  final VoidCallback? eliminar;
  final ValueChanged<Icon>?
  cambiarIcono; //avisamos a la pantalla cuando el usuario cambia a otro icono

  TarjetaHabito({
    super.key,
    this.nombre = '',
    required this.color,
    required this.completado,
    this.icono = const Icon(Icons.water, color: colorPredefinido),
    this.completar,
    this.editar,
    this.eliminar,
    this.cambiarIcono,
  });

  // Declaro el estilo para no repetir codigo
  static final ButtonStyle estilo = ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(0),
    alignment: Alignment.center,
    fixedSize: const Size(40, 40),
    minimumSize: const Size(0, 0),
    maximumSize: const Size(50, 50),
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          // Si le hemos pasado la funcion estamos estamos en habitos_page
          if (completar != null)
            Checkbox(value: completado, onChanged: completar),
          if (completar != null) Expanded(child: icono),

          Expanded(
            child: Text(nombre, style: TextStyle(color: color)),
          ),

          if (editar != null)
            ElevatedButton(
              onPressed: editar,
              style: estilo,

              child: const Icon(Icons.edit),
            ),

          if (eliminar != null)
            ElevatedButton(
              onPressed: eliminar,
              style: estilo,
              child: const Icon(Icons.delete),
            ),
        ],
      ),
    );
  }
}
