import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:_2048/data/partida_guardada_dao.dart';
import 'package:_2048/models/colores.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:_2048/widgets/boardwidget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/partida_dao.dart';
import '../models/cuadrado.dart';
import '../models/partida_guardada.dart';
import '../models/tablero.dart';
import '../routes.dart';

class Juego2048 extends StatefulWidget {
  const Juego2048({super.key});

  @override
  State<Juego2048> createState() => _Juego2048State();
}

class _Juego2048State extends State<Juego2048> with WidgetsBindingObserver {
  final colores = obtenerEsquemaColoresActual(
    PreferenciasService.instanciaPS.obtenerTemaOscuro(),
  );

  final stopWatch = Stopwatch();
  late final Timer timer;
  String tiempoPasado = '0';

  List<Container> gridVisual = [];
  LinkedHashMap<String, Cuadrado> tableroActual = LinkedHashMap();
  final Tablero tableroUtils = Tablero();

  int puntuacion = 0;
  int mejorPuntuacion = 0;
  int movimientos = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    stopWatch.start();
    // Create a timer that runs a callback every 100 milliseconds to update UI
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        // Update elapsed time only if the stopwatch is running
        if (stopWatch.isRunning) {
          tiempoPasado = _formatearTiempo(stopWatch.elapsed);
        }
      });
    });

    tableroActual = LinkedHashMap.from(tableroUtils.tablero);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      PartidaGuardada partida = PartidaGuardada(
        movimientos: movimientos,
        puntuacion: puntuacion,
        segundosTranscurridos: stopWatch.elapsed.inSeconds,
        tablero: tableroUtils.toJson(tableroActual),
        id: 1,
        usuarioId: PreferenciasService.instanciaPS.obtenerUsuarioId()!,
      );
      PartidaGuardadaDao().guardarPartida(partida);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    gridVisual.clear();
    tableroActual.forEach(
      (key, value) => gridVisual.add(value.toContainer(context)),
    );

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Puntuacion: $puntuacion'),
            Text('Mejor Puntuacion: $mejorPuntuacion'),
            Text('Contador movimientos: $movimientos'),
            Text('Cronometro: $tiempoPasado'),

            BoardWidget(
              gridVisual: gridVisual,
              onHorizontalDragEnd: onHorizontalDragEnd,
              onVerticalDragEnd: onVerticalDragEnd,
            ),
            ElevatedButton(
              onPressed: () => context.pushReplacementNamed(Rutas.juego2048),
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
                'Reiniciar',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: colores[NombreColores.principal]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearTiempo(Duration tiempo) {
    return '${tiempo.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(tiempo.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(tiempo.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  void onHorizontalDragEnd(DragEndDetails a) {
    final x = a.primaryVelocity;
    if (x != null) {
      movimientos++;
      if (x > 0) {
        print('DERECHA');
        _DeslizarDerecha();
        _generarNuevoCuadrado();
        _ActualizarPosiciones();
      } else if (x < 0) {
        print('IZQUIERDA');
        _DeslizarIzquierda();
        _generarNuevoCuadrado();
        _ActualizarPosiciones();
      }
    }
  }

  void onVerticalDragEnd(DragEndDetails a) {
    final y = a.primaryVelocity;

    if (y != null) {
      movimientos++;
      if (y > 0) {
        print('ABAJO');
        _DeslizarAbajo();
        _generarNuevoCuadrado();
        _ActualizarPosiciones();
      } else if (y < 0) {
        print('ARRIBA');
        _DeslizarArriba();
        _generarNuevoCuadrado();
        _ActualizarPosiciones();
      }
    }
  }

  void _generarNuevoCuadrado() {
    List<String> posicionesValidas = [];

    tableroActual.forEach((key, cuadrado) {
      if (cuadrado.valor == 0) {
        posicionesValidas.add(key);
      }
    });

    if (posicionesValidas.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          titlePadding: EdgeInsets.all(16),
          title: Text(
            'GAME OVER',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.all(16),

          content: Text(
            'Puntuación: $puntuacion',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actionsPadding: EdgeInsets.all(16),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => context.pushReplacementNamed(Rutas.juego2048),
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
                'Volver a jugar',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: colores[NombreColores.principal]),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(flex: 1, child: SizedBox()),
            ElevatedButton(
              onPressed: () => context.goNamed(Rutas.principal),
              style: ElevatedButton.styleFrom(
                backgroundColor: colores[NombreColores.principal]!,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                fixedSize: Size(130, 50),
                padding: EdgeInsets.all(0),
              ),
              child: Text(
                'Volver al inicio',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: colores[NombreColores.superficie]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
      return;
    }

    final rand = Random.secure();

    bool encontrado = false;

    while (!encontrado) {
      int x = rand.nextInt(4);
      int y = rand.nextInt(4);

      String posicion = '$y$x';

      if (posicionesValidas.contains(posicion)) {
        print('Posicion encontrada: $posicion');
        tableroActual[posicion] = Cuadrado(valor: 2, posicion: posicion);
        encontrado = true;
      }
    }
  }

  void _ActualizarPosiciones() {
    LinkedHashMap<String, Cuadrado> nuevoTablero = LinkedHashMap.from(
      tableroUtils.tableroVacio,
    );
    tableroActual.forEach((posicion, cuadrado) {
      if (cuadrado.valor != 0) {
        cuadrado.combinado = false;
        nuevoTablero[cuadrado.posicion] = cuadrado;
      }
    });

    setState(() {
      tableroActual = nuevoTablero;
    });
  }

  void combinar(Cuadrado cuadradoActual, Cuadrado cuadradoSiguiente) {
    Cuadrado cuadradoNuevo = Cuadrado(
      posicion: cuadradoSiguiente.posicion,
      valor: cuadradoActual.valor + cuadradoSiguiente.valor,
    );

    cuadradoNuevo.combinado = true;

    tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
    tableroActual[cuadradoSiguiente.posicion] = cuadradoNuevo;

    puntuacion += cuadradoNuevo.valor;

    if (puntuacion > mejorPuntuacion) mejorPuntuacion = puntuacion;

    print(
      'Combinado: ${cuadradoActual.valor} en ${cuadradoActual.posicion} con ${cuadradoSiguiente.valor} en ${cuadradoSiguiente.posicion} resultado: ${cuadradoNuevo.valor} en ${cuadradoNuevo.posicion} prueba: ${tableroActual[cuadradoNuevo.posicion]?.valor}',
    );
  }

  _DeslizarIzquierda() {
    // Lineas 0 -> 3
    for (int i = 0; i < 4; i++) {
      // Columnas 1 -> 3
      for (int j = 1; j < 4; j++) {
        Cuadrado cuadradoActual = tableroActual['$i$j']!;

        if (cuadradoActual.valor != 0) {
          bool terminado = false;
          for (int k = j - 1; k >= 0 && !terminado; k--) {
            Cuadrado cuadradoSiguiente = tableroActual['$i$k']!;

            if (cuadradoSiguiente.valor != 0) {
              if (cuadradoActual.valor == cuadradoSiguiente.valor &&
                  cuadradoActual.combinado == false &&
                  cuadradoSiguiente.combinado == false) {
                combinar(cuadradoActual, cuadradoSiguiente);
                terminado = true;
              } else {
                tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
                cuadradoActual.keyX = '${k + 1}';
                tableroActual[cuadradoActual.posicion] = cuadradoActual;
                terminado = true;
              }
            } else if (k == 0) {
              tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
              cuadradoActual.keyX = '$k';
              tableroActual[cuadradoActual.posicion] = cuadradoActual;
              terminado = true;
            }
          }
        }
      }
    }
  }

  _DeslizarDerecha() {
    // Lineas 0 -> 3
    for (int i = 0; i < 4; i++) {
      // Columnas 3 -> 1
      for (int j = 3; j >= 0; j--) {
        Cuadrado cuadradoActual = tableroActual['$i$j']!;

        if (cuadradoActual.valor != 0) {
          bool terminado = false;
          for (int k = j + 1; k < 4 && !terminado; k++) {
            Cuadrado cuadradoSiguiente = tableroActual['$i$k']!;

            if (cuadradoSiguiente.valor != 0) {
              if (cuadradoActual.valor == cuadradoSiguiente.valor &&
                  cuadradoActual.combinado == false &&
                  cuadradoSiguiente.combinado == false) {
                combinar(cuadradoActual, cuadradoSiguiente);
                terminado = true;
              } else {
                tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
                cuadradoActual.keyX = '${k - 1}';
                tableroActual[cuadradoActual.posicion] = cuadradoActual;
                terminado = true;
              }
            } else if (k == 3) {
              tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
              cuadradoActual.keyX = '$k';
              tableroActual[cuadradoActual.posicion] = cuadradoActual;
              terminado = true;
            }
          }
        }
      }
    }
  }

  _DeslizarArriba() {
    // Columnas 0 -> 3
    for (int i = 0; i < 4; i++) {
      // Lineas 1 -> 3
      for (int j = 1; j < 4; j++) {
        Cuadrado cuadradoActual = tableroActual['$j$i']!;

        if (cuadradoActual.valor != 0) {
          bool terminado = false;
          for (int k = j - 1; k >= 0 && !terminado; k--) {
            Cuadrado cuadradoSiguiente = tableroActual['$k$i']!;

            if (cuadradoSiguiente.valor != 0) {
              if (cuadradoActual.valor == cuadradoSiguiente.valor &&
                  cuadradoActual.combinado == false &&
                  cuadradoSiguiente.combinado == false) {
                combinar(cuadradoActual, cuadradoSiguiente);
                terminado = true;
              } else {
                tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
                cuadradoActual.keyY = '${k + 1}';
                tableroActual[cuadradoActual.posicion] = cuadradoActual;
                terminado = true;
              }
            } else if (k == 0) {
              tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
              cuadradoActual.keyY = '$k';
              tableroActual[cuadradoActual.posicion] = cuadradoActual;
              terminado = true;
            }
          }
        }
      }
    }
  }

  _DeslizarAbajo() {
    // Columnas 0 -> 3
    for (int i = 0; i < 4; i++) {
      // Lineas 3 -> 1
      for (int j = 3; j >= 0; j--) {
        Cuadrado cuadradoActual = tableroActual['$j$i']!;

        if (cuadradoActual.valor != 0) {
          bool terminado = false;
          for (int k = j + 1; k < 4 && !terminado; k++) {
            Cuadrado cuadradoSiguiente = tableroActual['$k$i']!;

            if (cuadradoSiguiente.valor != 0) {
              if (cuadradoActual.valor == cuadradoSiguiente.valor &&
                  cuadradoActual.combinado == false &&
                  cuadradoSiguiente.combinado == false) {
                combinar(cuadradoActual, cuadradoSiguiente);
                terminado = true;
              } else {
                tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
                cuadradoActual.keyY = '${k - 1}';
                tableroActual[cuadradoActual.posicion] = cuadradoActual;
                terminado = true;
              }
            } else if (k == 3) {
              tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
              cuadradoActual.keyY = '$k';
              tableroActual[cuadradoActual.posicion] = cuadradoActual;
              terminado = true;
            }
          }
        }
      }
    }
  }
}
