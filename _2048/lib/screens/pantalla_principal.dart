import 'package:_2048/routes.dart';
import 'package:_2048/widgets/boton_principal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/iconos.dart';
import '../widgets/boardwidget.dart';
import '../widgets/boton_esquina.dart';
import '/models/colores.dart';
import '/services/preferenciasservice.dart';

import '../models/usuario.dart';
import '../data/databasehelper.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  Widget build(BuildContext context) {
    final Map<String, Color> colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(),
    );
    bool modo = PreferenciasService.instanciaPS.obtenerTemaOscuro();
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BotonEsquina(
                  texto: 'Comenzar',
                  icono: listaIconos[NombreIconos.ajustes]!,
                  pulsar: () => context.goNamed(Rutas.ajustes),
                ),
              ],
            ),

            Expanded(child: const SizedBox()),
            Text('2048:', style: Theme.of(context).textTheme.titleLarge),
            Text(
              '${modo ? 'Price' : 'Meowscarada'}\'s version',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const Expanded(flex: 3, child: const SizedBox()),
            BotonPrincipal(
              texto: 'Jugar',
              pulsar: () => context.goNamed(Rutas.juego2048),
            ),
            const SizedBox(height: 10),
            BotonPrincipal(
              texto: 'Historial',
              pulsar: () => context.goNamed(Rutas.historial),
            ),
            const SizedBox(height: 10),
            BotonPrincipal(
              texto: 'Ranking',
              pulsar: () => context.goNamed(Rutas.ranking),
            ),
            const SizedBox(height: 10),
            BotonPrincipal(
              texto: 'Estadisticas',
              pulsar: () => context.goNamed(Rutas.estadisticas),
            ),
            Expanded(flex: 2, child: const SizedBox()),
          ],
        ),
      ),
    );
  }
}
