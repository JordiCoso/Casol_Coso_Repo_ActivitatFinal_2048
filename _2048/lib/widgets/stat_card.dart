import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;

  const StatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 32),

          const SizedBox(height: 8),

          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            valor,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
