import 'package:_2048/routes.dart';
import 'package:_2048/widgets/boton_principal.dart';
import 'package:cryptography/helpers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/partida_guardada_dao.dart';
import '../models/iconos.dart';
import '../models/partida_guardada.dart';
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
  PartidaGuardada? partidaGuardada;

  @override
  void initState() {
    super.initState();
    comprobarPartidaGuardada();
  }

  //comprobamos si hay una partida guardada
  Future<void> comprobarPartidaGuardada() async {
    int? usuarioId = PreferenciasService.instanciaPS.obtenerUsuarioId();

    if (usuarioId != null) {
      partidaGuardada = await PartidaGuardadaDao().obtenerPartidaGuardada(
        usuarioId,
      );

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(context),
    );
    bool modo = PreferenciasService.instanciaPS.obtenerTemaOscuro(context);
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
            const Expanded(flex: 2, child: const SizedBox()),
            Image(
              image: modo
                  ? const AssetImage('images/2048_Icon_Dark.png')
                  : const AssetImage('images/2048_Icon_Light.png'),
              height: 250,
              width: 250,
            ),
            const Expanded(flex: 3, child: const SizedBox()),
            BotonPrincipal(
              texto: 'Jugar',
              pulsar: () async {
                await context.pushNamed(Rutas.juego2048);
                comprobarPartidaGuardada();
              },
            ),

            if (partidaGuardada != null) SizedBox(height: 10),

            if (partidaGuardada != null)
              BotonPrincipal(
                texto: 'Continuar partida',
                pulsar: () async {
                  await context.pushNamed(
                    Rutas.juego2048,
                    extra: partidaGuardada,
                  );
                  comprobarPartidaGuardada();
                },
              ),
            SizedBox(height: 10),
            BotonPrincipal(
              texto: 'Cómo se juega',
              pulsar: () => context.goNamed(Rutas.comoJugar),
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
            Expanded(flex: 4, child: const SizedBox()),
          ],
        ),
      ),
    );
  }
}
