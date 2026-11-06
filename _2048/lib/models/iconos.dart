import 'package:flutter/material.dart';

class NombreIconos {
  NombreIconos._nollamar();

  static const gota = 'Gota';
  static const correr = 'Correr';
  static const hierba = 'Hierba';
}

const Map<String, IconData> opcionesIconos = {
  NombreIconos.gota: Icons.water_drop,
  NombreIconos.correr: Icons.directions_run,
  NombreIconos.hierba: Icons.grass,
};
