import 'package:flutter/material.dart';

class AsyncDataView extends StatelessWidget {
  final bool cargando;
  final bool error;
  final VoidCallback onReintentar;

  const AsyncDataView({
    super.key,
    required this.cargando,
    required this.error,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: Text('Cargando datos...'));
    }

    if (error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Error al cargar los datos'),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text(''));
  }
}
