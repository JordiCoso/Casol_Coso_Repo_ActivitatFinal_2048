import 'package:flutter/material.dart';

class BotonSelecionColor extends StatelessWidget {
  final VoidCallback pulsar;
  final Color color;

  const BotonSelecionColor({
    super.key,
    required this.pulsar,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: pulsar,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(0),
        alignment: Alignment.center,
        fixedSize: const Size(0, 40),
        minimumSize: const Size(0, 0),
        maximumSize: const Size(0, 25),
      ),
      child: const Text(''),
    );
  }
}
