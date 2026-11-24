import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:_2048/data/partida_guardada_dao.dart';
import 'package:_2048/models/colores.dart';
import 'package:_2048/models/iconos.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:_2048/widgets/boardwidget.dart';
import 'package:_2048/widgets/boton_esquina.dart';
import 'package:_2048/widgets/cronometroWidget.dart';
import 'package:_2048/widgets/scorecard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/partida_dao.dart';
import '../models/cuadrado.dart';
import '../models/partida.dart';
import '../models/partida_guardada.dart';
import '../models/tablero.dart';
import '../routes.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/tilewidget.dart';

class Juego2048 extends StatefulWidget {
  final PartidaGuardada? partidaGuardada;

  const Juego2048({super.key, this.partidaGuardada});

  @override
  State<Juego2048> createState() => _Juego2048State();
}

class _Juego2048State extends State<Juego2048> with WidgetsBindingObserver {
  double escala = 1;
  late CronometroWidget cronometro;

  //animamos la ficha nueva
  void funcEscalar() {
    setState(() {
      escala = 1.15;
    });

    Future.delayed(Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          escala = 1;
        });
      }
    });
  }

  //mostramos u ocultamos los detalles de la partida
  void cambiarVisibilidadDetalles() {
    setState(() {
      mostrarDetalles = !mostrarDetalles;
    });
  }

  late Map<String, Color> colores;

  List<TileWidget> gridVisual = [];
  LinkedHashMap<String, Cuadrado> tableroActual = LinkedHashMap();
  final Tablero tableroUtils = Tablero();

  int puntuacion = 0;
  int mejorPuntuacion = 0;
  int movimientos = 0;
  int fichaMaxima = 0;
  bool partidaFinalizada = false;
  bool mostrarDetalles = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.partidaGuardada != null) {
      PartidaGuardada partida = widget.partidaGuardada!;

      Tablero tableroGuardado = Tablero.fromJson(partida.tablero);

      tableroActual = LinkedHashMap.from(tableroGuardado.tablero);

      puntuacion = partida.puntuacion;
      movimientos = partida.movimientos;

      cronometro = CronometroWidget(
        tiempoEnSegundos: partida.segundosTranscurridos,
      );

      //obtenemos la ficha maxima del tablero
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          Cuadrado cuadradoActual = tableroActual['$i$j']!;

          if (cuadradoActual.valor > fichaMaxima) {
            fichaMaxima = cuadradoActual.valor;
          }
        }
      }
    } else {
      tableroActual = LinkedHashMap.from(tableroUtils.tablero);
      cronometro = CronometroWidget();

      _generarNuevoCuadrado();
      _generarNuevoCuadrado();

      fichaMaxima = 2;
    }

    mejorPuntuacion = PreferenciasService.instanciaPS.obtenerMejorPuntuacion();

    if (puntuacion > mejorPuntuacion) {
      mejorPuntuacion = puntuacion;
    }
  }

  //guardamos la partida actual
  Future<void> guardarPartida() async {
    if (partidaFinalizada) return;
    PartidaGuardada partida = PartidaGuardada(
      movimientos: movimientos,
      puntuacion: puntuacion,
      segundosTranscurridos: cronometro.tiempoEnSegundos,
      tablero: tableroUtils.toJson(tableroActual),
      id: 1,
      usuarioId: PreferenciasService.instanciaPS.obtenerUsuarioId()!,
    );

    await PartidaGuardadaDao().guardarPartida(partida);
  }

  //reiniciamos la partida
  Future<void> reiniciarPartida() async {
    partidaFinalizada = true;

    int usuarioId = PreferenciasService.instanciaPS.obtenerUsuarioId()!;

    await PartidaGuardadaDao().eliminarPartidaGuardada(usuarioId);

    if (mounted) {
      context.pushReplacementNamed(Rutas.juego2048);
    }
  }

  //guardamos la partida terminada en el historial
  Future<void> finalizarPartida() async {
    if (partidaFinalizada) return;

    partidaFinalizada = true;

    Partida partida = Partida(
      usuarioId: PreferenciasService.instanciaPS.obtenerUsuarioId()!,
      usuario: PreferenciasService.instanciaPS.obtenerUltimoJugador(),
      puntuacion: puntuacion,
      fichaMaxima: fichaMaxima,
      movimientos: movimientos,
      duracionSegundos: cronometro.tiempoEnSegundos,
      fecha: DateTime.now().toIso8601String(),
    );

    await PartidaDao().finalizarPartida(partida);

    PreferenciasService.instanciaPS.guardarMejorPuntuacion(puntuacion);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive && !partidaFinalizada) {
      await guardarPartida();
      print('GUARDADA');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(context),
    );
    gridVisual.clear();
    tableroActual.forEach(
      (key, value) => gridVisual.add(
        TileWidget(valor: value.valor, escala: escala, nuevo: value.nuevo),
      ),
    );
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await salirPartida();
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              BotonEsquina(
                pulsar: salirPartida,
                texto: 'Volver',
                icono: listaIconos[NombreIconos.inicio]!,
              ),

              Expanded(child: const SizedBox()),
              GestureDetector(
                onDoubleTap: cambiarVisibilidadDetalles,
                child: Scorecard(etiqueta: 'Puntuacion', valor: puntuacion),
              ),
              Scorecard(etiqueta: 'Mejor Puntuacion', valor: mejorPuntuacion),
              Visibility(
                visible: mostrarDetalles,
                child: Text('Contador movimientos: $movimientos'),
              ),
              Visibility(
                visible: mostrarDetalles,
                maintainState: true,
                child: cronometro,
              ),
              Expanded(child: const SizedBox()),
              BoardWidget(
                gridVisual: gridVisual,
                onHorizontalDragEnd: onHorizontalDragEnd,
                onVerticalDragEnd: onVerticalDragEnd,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(listaIconos[NombreIconos.flechaArriba]),
                    onPressed: () {
                      moverFichas('arriba');
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(listaIconos[NombreIconos.flechaIzquierda]),
                    onPressed: () {
                      moverFichas('izquierda');
                    },
                  ),
                  IconButton(
                    icon: Icon(listaIconos[NombreIconos.flechaAbjo]),
                    onPressed: () {
                      moverFichas('abajo');
                    },
                  ),
                  IconButton(
                    icon: Icon(listaIconos[NombreIconos.flechaDerecha]),
                    onPressed: () {
                      moverFichas('derecha');
                    },
                  ),
                ],
              ),
              Expanded(child: const SizedBox()),
              ElevatedButton(
                onPressed: reiniciarPartida,
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
              Expanded(child: const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  //movemos las fichas mediante los botones o gestos
  void moverFichas(String direccion) {
    if (partidaFinalizada) return;

    String tableroAnterior = tableroUtils.toJson(tableroActual);

    if (direccion == 'arriba') {
      _DeslizarArriba();
    } else if (direccion == 'abajo') {
      _DeslizarAbajo();
    } else if (direccion == 'izquierda') {
      _DeslizarIzquierda();
    } else if (direccion == 'derecha') {
      _DeslizarDerecha();
    }

    String tableroNuevo = tableroUtils.toJson(tableroActual);

    if (tableroAnterior != tableroNuevo) {
      movimientos++;
      _generarNuevoCuadrado();
      _ActualizarPosiciones();
      funcEscalar();
    }

    comprobarFinPartida();
  }

  void onHorizontalDragEnd(DragEndDetails a) {
    final x = a.primaryVelocity;

    if (x != null) {
      if (x > 1000) {
        moverFichas('derecha');
      } else if (x < -1000) {
        moverFichas('izquierda');
      }
    }
  }

  void onVerticalDragEnd(DragEndDetails a) {
    final y = a.primaryVelocity;

    if (y != null) {
      if (y > 1000) {
        moverFichas('abajo');
      } else if (y < -1000) {
        moverFichas('arriba');
      }
    }
  }

  //comprobamos si quedan movimientos posibles
  bool hayMovimientosPosibles() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        Cuadrado cuadradoActual = tableroActual['$i$j']!;

        //comprobamos si hay una casilla vacia
        if (cuadradoActual.valor == 0) {
          return true;
        }

        //comprobamos la ficha de la derecha
        if (j < 3) {
          Cuadrado cuadradoSiguiente = tableroActual['$i${j + 1}']!;

          if (cuadradoActual.valor == cuadradoSiguiente.valor) {
            return true;
          }
        }

        //comprobamos la ficha de abajo
        if (i < 3) {
          Cuadrado cuadradoSiguiente = tableroActual['${i + 1}$j']!;

          if (cuadradoActual.valor == cuadradoSiguiente.valor) {
            return true;
          }
        }
      }
    }

    return false;
  }

  //comprobamos si la partida ha terminado
  Future<void> comprobarFinPartida() async {
    if (partidaFinalizada) return;
    if (hayMovimientosPosibles()) return;

    await finalizarPartida();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
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
            onPressed: () {
              Navigator.pop(context);
              reiniciarPartida();
            },
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
          SizedBox(width: 10),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(this.context);
            },
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
  }

  void _generarNuevoCuadrado() {
    List<String> posicionesValidas = [];

    tableroActual.forEach((key, cuadrado) {
      if (cuadrado.nuevo) cuadrado.nuevo = false;
      if (cuadrado.valor == 0) posicionesValidas.add(key);
    });

    if (posicionesValidas.isEmpty) {
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

        tableroActual[posicion] = Cuadrado(
          valor: 2,
          posicion: posicion,
          nuevo: true,
        );

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

    if (cuadradoNuevo.valor > fichaMaxima) fichaMaxima = cuadradoNuevo.valor;

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

  //comprobamos si el usuario quiere guardar antes de salir
  Future<void> salirPartida() async {
    final bool? guardarAntesSalir = await _showBackDialog();

    if (guardarAntesSalir == null) return;

    //confirmamos que el usuario quiere salir sin guardar
    if (guardarAntesSalir == false) {
      final bool? confirmarSalida = await showDialog<bool>(
        context: context,
        builder: (context) => ConfirmDialog(
          titulo: 'Salir sin guardar',
          mensaje:
              'Perderás el progreso que no hayas guardado. ¿Quieres continuar?',
          textoConfirmar: 'Salir',
          textoCancelar: 'Cancelar',
          onConfirmar: () {
            Navigator.pop(context, true);
          },
          onCancelar: () {
            Navigator.pop(context, false);
          },
        ),
      );

      if (confirmarSalida != true) return;
    }

    if (guardarAntesSalir == true) {
      try {
        await guardarPartida();
      } catch (e) {
        if (!mounted) return;

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('No se ha podido guardar la partida.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Aceptar'),
              ),
            ],
          ),
        );

        return;
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          titulo: '¿Estás seguro?',
          mensaje: '¿Seguro que quieres salir de esta página?',
          textoConfirmar: 'Guardar y salir',
          textoCancelar: 'Cancelar',
          textoAdicional: 'Salir sin guardar',
          onConfirmar: () {
            Navigator.pop(context, true);
          },
          onCancelar: () {
            Navigator.pop(context, null);
          },
          onAdicional: () {
            Navigator.pop(context, false);
          },
        );
      },
    );
  }
}
