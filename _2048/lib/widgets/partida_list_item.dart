import 'package:flutter/material.dart';

import '../models/partida.dart';

class PartidaListItem extends StatelessWidget {
  final Partida partida;
  final VoidCallback onPulsar;
  final VoidCallback? onPulsacionLarga;

  const PartidaListItem({
    super.key,
    required this.partida,
    required this.onPulsar,
    this.onPulsacionLarga,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPulsar,
      onLongPress: onPulsacionLarga,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              partida.usuario,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 8),

            Text('Puntuación: ${partida.puntuacion}'),

            const SizedBox(height: 4),

            Text('Ficha máxima: ${partida.fichaMaxima}'),

            const SizedBox(height: 4),

            Text('Movimientos: ${partida.movimientos}'),

            const Divider(),
          ],
        ),
      ),
    );
  }
}
