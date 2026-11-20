import 'package:_2048/screens/pantalla_principal.dart';
import 'package:_2048/screens/splash_screen.dart';
import 'package:_2048/data/databasehelper.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/usuario.dart';

class Rutas {
  static const principal = 'principal';
  static const splashScreen = 'splashScreen';
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: Rutas.splashScreen,
      builder: (context, state) {
        return SplashScreen(
          preferenciasService: state.extra as PreferenciasService,
        );
      },
      routes: [
        GoRoute(
          path: '${Rutas.splashScreen}/${Rutas.principal}',
          name: Rutas.principal,
          builder: (context, state) {
            Map<String, Object> BBDDPreferences =
                state.extra as Map<String, Object>;
            return PantallaPrincipal(
              preferenciasService:
                  BBDDPreferences['Preferences'] as PreferenciasService,
              usuario: Usuario(nombre: '', numeroHabitos: 2),
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Ruta no encontrada')),
    body: Center(
      child: TextButton(
        onPressed: () => context.goNamed(Rutas.splashScreen),
        child: const Text('Volver a la lista'),
      ),
    ),
  ),
);
