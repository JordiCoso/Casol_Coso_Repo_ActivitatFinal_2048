import 'package:flutter/material.dart';

import '../models/cuadrado.dart';
import '../models/tablero.dart';

class BoardWidget extends StatefulWidget {
  final int? tamanoTablero;
  late final Tablero tablero;

  BoardWidget({super.key, this.tamanoTablero}) {
    tablero =
    tamanoTablero == null ? Tablero() : Tablero(tamanoTablero: tamanoTablero!);
  }

  @override
  State<StatefulWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  Color color = Color(0xFFFF0000);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: color,
        height: 350,
        width: 350,
        child: Column(
          children: [
            Row(
              children: [
                Container(child: Text('0')),
                Container(child: Text('1')),
                Container(child: Text('2')),
                Container(child: Text('3')),
              ],
            ),
            Row(
              children: [
                Container(child: Text('0')),
                Container(child: Text('1')),
                Container(child: Text('2')),
                Container(child: Text('3')),
              ],
            ),
            Row(
              children: [
                Container(child: Text('0')),
                Container(child: Text('1')),
                Container(child: Text('2')),
                Container(child: Text('3')),
              ],
            ),
          ],
        ),
      ),
      onHorizontalDragUpdate: (DragUpdateDetails a) {
        setState(() {
          final x = a.primaryDelta;
          if (x != null) {
            if (x > 0) {
              color = Color(0xFF00FF00);
            } else if (x < 0) {
              color = Color(0xFF000000);
            }
          }
        });
      },
      onVerticalDragUpdate: (DragUpdateDetails a) {
        setState(() {
          final y = a.primaryDelta;
          if (y != null) {
            if (y > 0) {
              color = Color(0xFF0000FF);
            } else if (y < 0) {
              color = Color(0xFFFFFFFF);
            }
          }
        });
      },
    );
  }

 /* _ActualizarPosiciones() {
    Map<String, Cuadrado> tablero;
    Map<String, Cuadrado> nuevoTablero = widget.tableroVacio;
    tablero.forEach((posicion, cuadrado) {
      if (cuadrado.valor != 0) {
        nuevoTablero[posicion] = cuadrado;
      }
    });
  }
}*/

/* _DeslizarIzquierda() {
    // Lineas 0 -> 3
    for (int i = 0; i < 4; i++) {
      // Columnas 1 -> 3
      for (int j = 1; j < 4; j++) {
        Cuadrado cuadradoActual = cuadradosMap['$i$j'];

        if (cuadradoActual.valor != 0) {
          bool terminado = false;
          for (int k = j - 1; k >= 0 && !terminado; k--) {
            Cuadrado cuadradoSiguiente = cuadradosMap['$i$k'];

            if (cuadradoSiguiente.valor != 0) {
              if (cuadradoActual.valor == cuadradoSiguiente.valor) {
                combinar(cuadradoActual, cuadradoSiguiente);
                terminado = true;
              } else {
                cuadradoActual.posicion.x = k + 1;
                terminado = true;
              }
            } else if (k == 0) {
              cuadradoActual.posicion.x = k;
              terminado = true;
            }
          }
        }
      }
    }
  }

  _DeslizarDerecha() {
    for (int i = 0; i < 4; i++) {
      // Columnas 3 -> 1
      for (int j = 3; j > 0; j--) {
        Cuadrado cuadradoActual = cuadradosMap['$i$j'];

        if (cuadradoActual.valor != 0) {
          bool terminado = false;
          for (int k = j + 1; k < 4 && !terminado; k++) {
            Cuadrado cuadradoSiguiente = cuadradosMap['$i$k'];

            if (cuadradoSiguiente.valor != 0) {
              if (cuadradoActual.valor == cuadradoSiguiente.valor) {
                combinar(cuadradoActual, cuadradoSiguiente);
                terminado = true;
              } else {
                cuadradoActual.posicion.x = k - 1;
                terminado = true;
              }
            } else if (k == 0) {
              cuadradoActual.posicion.x = k;
              terminado = true;
            }
          }
        }
      }
    }
  }

  _DeslizarArriba() {
    // Columnas 0 -> 3
    for (int j = 0; j < 4; j++) {
      // Lineas 1 -> 3
      for (int i = 1; i < 4; i++) {
        Cuadrado cuadradoActual = cuadradosMap['$i$j'];

        if (cuadradoActual.valor != 0) {
          bool terminado = false;
          for (int k = i - 1; k >= 0 && !terminado; k--) {
            Cuadrado cuadradoSiguiente = cuadradosMap['$k$j'];

            if (cuadradoSiguiente.valor != 0) {
              if (cuadradoActual.valor == cuadradoSiguiente.valor) {
                combinar(cuadradoActual, cuadradoSiguiente);
                terminado = true;
              } else {
                cuadradoActual.posicion.y = k + 1;
                terminado = true;
              }
            } else if (k == 0) {
              cuadradoActual.posicion.y = k;
              terminado = true;
            }
          }
        }
      }
    }
  }

  _DeslizarAbajo() {
    // Columnas 0 -> 3
    for (int j = 0; j < 4; j++) {
      // Lineas 3 -> 1
      for (int i = 3; i > 0; i--) {
        Cuadrado cuadradoActual = cuadradosMap['$i$j'];

        if (cuadradoActual.valor != 0) {
          bool terminado = false;
          for (int k = i + 1; k < 4 && !terminado; k++) {
            Cuadrado cuadradoSiguiente = cuadradosMap['$k$i'];

            if (cuadradoSiguiente.valor != 0) {
              if (cuadradoActual.valor == cuadradoSiguiente.valor) {
                combinar(cuadradoActual, cuadradoSiguiente);
                terminado = true;
              } else {
                cuadradoActual.posicion.y = k - 1;
                terminado = true;
              }
            } else if (k == 0) {
              cuadradoActual.posicion.y = k;
              terminado = true;
            }
          }
        }
      }
    }
  }*/
}
