import 'package:_2048/widgets/boardwidget.dart';
import 'package:flutter/material.dart';

class Juego2048 extends StatelessWidget {
  const Juego2048({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Puntuacion'),
            Text('Mejor Puntuacion'),
            Text('Contador movimientos'),
            Text('Cronometro'),

            BoardWidget(),
            Text('Boton de reinicio'),
          ],
        ),
      ),
    );
  }
}
