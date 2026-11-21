import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final Color color;

  const EmptyStateView({
    super.key,
    required this.mensaje,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 48, color: color),

          const SizedBox(height: 16),

          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
