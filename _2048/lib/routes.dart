import 'package:_2048/screens/como_jugar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/screens/splash_screen.dart';
import '/screens/login_page.dart';
import '/screens/registro_page.dart';
import '/screens/pantalla_principal.dart';
import '/screens/ajustes.dart';
import '/screens/historial_page.dart';
import '/screens/detalles_partida_page.dart';
import '/screens/ranking_page.dart';
import '/screens/estadisticas_page.dart';
import '/screens/juego2048.dart';
import 'models/partida_guardada.dart';

class Rutas {
  static const String parametroDetallePartidaID = 'id';

  static const String splashScreen = 'splashScreen';
  static const String login = 'login';
  static const String registrar = 'registrar';
  static const String principal = 'principal';
  static const String ajustes = 'ajustes';
  static const String historial = 'historial';
  static const String detallePartida = 'detallePartida';
  static const String ranking = 'ranking';
  static const String estadisticas = 'estadisticas';
  static const String juego2048 = 'juego2048';
  static const String comoJugar = 'comoJugar';
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: Rutas.splashScreen,
      builder: (context, state) => SplashScreen(),
      routes: [
        GoRoute(
          path: Rutas.login,
          name: Rutas.login,
          builder: (context, state) => LoginPage(),
          routes: [
            GoRoute(
              path: Rutas.registrar,
              name: Rutas.registrar,
              builder: (context, state) => RegistroPage(),
            ),
            GoRoute(
              path: Rutas.principal,
              name: Rutas.principal,
              builder: (context, state) => PantallaPrincipal(),
              routes: [
                GoRoute(
                  path: Rutas.ajustes,
                  name: Rutas.ajustes,
                  builder: (context, state) => PantallaAjustes(),
                ),
                GoRoute(
                  path: Rutas.historial,
                  name: Rutas.historial,
                  builder: (context, state) => HistorialPage(),
                  routes: [
                    GoRoute(
                      path: '${Rutas.detallePartida}/:id',
                      name: Rutas.detallePartida,
                      builder: (context, state) => DetallesPartidaPage(
                        idPartida: state
                            .pathParameters[Rutas.parametroDetallePartidaID]!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: Rutas.ranking,
                  name: Rutas.ranking,
                  builder: (context, state) => RankingPage(),
                ),
                GoRoute(
                  path: Rutas.estadisticas,
                  name: Rutas.estadisticas,
                  builder: (context, state) => EstadisticasPage(),
                ),
                GoRoute(
                  path: Rutas.juego2048,
                  name: Rutas.juego2048,
                  builder: (context, state) => Juego2048(partidaGuardada: state.extra as PartidaGuardada?,),
                ),
                GoRoute(
                  path: Rutas.comoJugar,
                  name: Rutas.comoJugar,
                  builder: (context, state) => ComoJugar(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Ruta no encontrada')),
    body: Center(
      child: TextButton(
        onPressed: () => context.goNamed(Rutas.splashScreen),
        child: const Text('Volver a menu principal'),
      ),
    ),
  ),
);
