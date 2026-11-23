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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BotonEsquina(
                  texto: 'Comenzar',
                  icono: listaIconos[NombreIconos.ajustes]!,
                  pulsar: () async {
                    ThemeMode? modo = await showDialog<ThemeMode>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          titlePadding: EdgeInsets.all(16),
                          title: Text(
                            '¿Cambiar el tema de la app?',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          contentPadding: EdgeInsets.all(16),

                          actionsPadding: EdgeInsets.all(16),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, ThemeMode.light),
                                  child: Text('Modo claro'),
                                ),

                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, ThemeMode.dark),
                                  child: Text('Modo oscuro'),
                                ),

                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, ThemeMode.system),
                                  child: Text('Tema del sistema'),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );

                    if (modo == null) return;

                    PreferenciasService.instanciaPS.guardarModoTema(modo);
                  },
                ),
              ],
            ),
            const Expanded(flex: 3, child: SizedBox()),
            const Image(
              image: AssetImage('images/logo_2048_sinFondo.png'),
              height: 150,
              width: 150,
            ),
            Text('2048', style: Theme.of(context).textTheme.titleLarge),
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
