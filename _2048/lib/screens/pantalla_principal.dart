import 'package:flutter/material.dart';

import '../widgets/boardwidget.dart';
import '/models/colores.dart';
import '/services/preferenciasservice.dart';

import '../models/usuario.dart';
import '../data/databasehelper.dart';

class PantallaPrincipal extends StatefulWidget {

  // final Databasehelper _databasehelper;
  final Usuario _usuario;

  const PantallaPrincipal({
    super.key,
    // required this._databasehelper,
    required this._usuario,
  });

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  late Map<String, Color> colores;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              'Nuestros servicios',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 200),
            BoardWidget(),
          ],
        ),
      ),
    );
  }
}
