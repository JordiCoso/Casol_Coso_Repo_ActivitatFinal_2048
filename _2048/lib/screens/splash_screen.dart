import 'package:_2048/screens/pantalla_principal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/usuario.dart';
import '../routes.dart';
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
      PreferenciasService.instanciaPS.obtenerTemaOscuro(),
    );

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
                  pulsar: () async {
                    bool? modo = await showDialog<bool>(
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

                          content: Text(
                            '¿Quieres el modo claro o el modo oscuro?',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          actionsPadding: EdgeInsets.all(16),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: ElevatedButton.styleFrom(
                                side: BorderSide(
                                  width: 1.5,
                                  color: colores[NombreColores.principal]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                fixedSize: Size(130, 50),
                                padding: EdgeInsets.all(0),
                              ),
                              child: Text(
                                'Modo claro',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: colores[NombreColores.principal],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(flex: 1, child: SizedBox()),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    colores[NombreColores.principal]!,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                fixedSize: Size(130, 50),
                                padding: EdgeInsets.all(0),
                              ),
                              child: Text(
                                'Modo oscuro',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: colores[NombreColores.superficie],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (modo == null) return;

                    PreferenciasService.instanciaPS.guardarTemaOscuro(modo);
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
