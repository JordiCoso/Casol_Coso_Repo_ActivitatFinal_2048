import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cuadrado.dart';
import '../models/tablero.dart';

class BoardWidget extends StatefulWidget {
  final int? tamanoTablero;
  late final Tablero tablero;

  BoardWidget({super.key, this.tamanoTablero}) {
    tablero = tamanoTablero == null
        ? Tablero()
        : Tablero(tamanoTablero: tamanoTablero!);
  }

  @override
  State<StatefulWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  Color color = Color(0xFFFF0000);
  List<Container> gridVisual = [];
  LinkedHashMap<String, Cuadrado> tableroActual = LinkedHashMap();

  @override
  void initState() {
    super.initState();
    tableroActual = LinkedHashMap.from(widget.tablero.tablero);
  }

  @override
  Widget build(BuildContext context) {
    gridVisual.clear();
    tableroActual.forEach((key, value) => gridVisual.add(value.toContainer(context)));

    for (int i = 0; i < gridVisual.length; i++) {
      print('${gridVisual[i]} numero: $i');
    }

    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        color: color,
        height: 350,
        width: 350,
        child: Wrap(runSpacing: 5, spacing: 5, children: gridVisual),
      ),
      onHorizontalDragEnd: (DragEndDetails a) {
        final x = a.primaryVelocity;
        if (x != null) {
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
      },
      onVerticalDragEnd: (DragEndDetails a) {
        final y = a.primaryVelocity;
        if (y != null) {
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
      },
    );
  }

  void _generarNuevoCuadrado() {
    List<String> posicionesValidas = [];

    tableroActual.forEach((key, cuadrado) {
      if (cuadrado.valor == 0) {
        posicionesValidas.add(key);
      }
    });

    if (posicionesValidas.isEmpty) {
      print('ESTA VACIO');
      context.pop();
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
      widget.tablero.tableroVacio,
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
                cuadradoActual.x = '${k + 1}';
                tableroActual[cuadradoActual.posicion] = cuadradoActual;
                terminado = true;
              }
            } else if (k == 0) {
              tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
              cuadradoActual.x = '$k';
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
                cuadradoActual.x = '${k - 1}';
                tableroActual[cuadradoActual.posicion] = cuadradoActual;
                terminado = true;
              }
            } else if (k == 3) {
              tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
              cuadradoActual.x = '$k';
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
                cuadradoActual.y = '${k + 1}';
                tableroActual[cuadradoActual.posicion] = cuadradoActual;
                terminado = true;
              }
            } else if (k == 0) {
              tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
              cuadradoActual.y = '$k';
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
                cuadradoActual.y = '${k - 1}';
                tableroActual[cuadradoActual.posicion] = cuadradoActual;
                terminado = true;
              }
            } else if (k == 3) {
              tableroActual[cuadradoActual.posicion] = Cuadrado.vacio();
              cuadradoActual.y = '$k';
              tableroActual[cuadradoActual.posicion] = cuadradoActual;
              terminado = true;
            }
          }
        }
      }
    }
  }
}
