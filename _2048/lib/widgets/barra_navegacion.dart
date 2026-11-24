import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/colores.dart';
import '../models/iconos.dart';
import '../services/preferenciasservice.dart';
import '../routes.dart';

class BarraNavegacion extends StatelessWidget {
  final int indiceActual;

  BarraNavegacion({super.key, required this.indiceActual});

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(context),
    );

    return BottomNavigationBar(
      currentIndex: indiceActual,
      type: BottomNavigationBarType.fixed,
      backgroundColor: colores[NombreColores.superficie],
      selectedItemColor: colores[NombreColores.principal],
      unselectedItemColor: colores[NombreColores.textoSecundario],

      onTap: (int indice) {
        if (indice == 0) {
          context.goNamed(Rutas.splashScreen);
        } else if (indice == 1) {
          context.goNamed(Rutas.historial);
        } else if (indice == 2) {
          context.goNamed(Rutas.ranking);
        } else if (indice == 3) {
          context.goNamed(Rutas.ajustes);
        }
      },

      items: [
        BottomNavigationBarItem(
          icon: Icon(listaIconos[NombreIconos.inicio]),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(listaIconos[NombreIconos.historial]),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(listaIconos[NombreIconos.ranking]),
          label: 'Ranking',
        ),
        BottomNavigationBarItem(
          icon: Icon(listaIconos[NombreIconos.ajustes]),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
