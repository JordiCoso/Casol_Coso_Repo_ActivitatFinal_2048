import 'package:_2048/screens/pantalla_principal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/usuario.dart';
import '../routes.dart';
import '../widgets/barra_navegacion.dart';
import '/models/colores.dart';
import '/models/iconos.dart';
import '/services/preferenciasservice.dart';
import '/widgets/boton_principal.dart';

import '../widgets/boton_esquina.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(context),
    );

    return Scaffold(
      bottomNavigationBar: BarraNavegacion(indiceActual: 0),
      body: Center(
        child: Column(
          children: [
            const Expanded(flex: 3, child: SizedBox()),
            const Image(
              image: AssetImage('images/2048_Icon_App.png'),
              height: 300,
              width: 300,
            ),
            const Expanded(flex: 2, child: SizedBox()),
            BotonPrincipal(
              texto: 'Comenzar',
              pulsar: () => context.goNamed(Rutas.login),
            ),
            const Expanded(flex: 2, child: SizedBox()),
          ],
        ),
      ),
    );
  }
}
