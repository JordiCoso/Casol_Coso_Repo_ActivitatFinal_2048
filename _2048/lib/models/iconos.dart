import 'package:flutter/material.dart';

class NombreIconos {
  const NombreIconos._nollamar();

  static const String inicio = 'Inicio';
  static const String personal = 'Personal';
  static const String clientes = 'Clientes';
  static const String servicios = 'Servicios';
  static const String cobros = 'Cobros';
  static const String cartera = 'Cartera';
  static const String flechaPequenaDerecha = 'Flecha';
  static const String iconoMasaje = 'Icono masaje';
  static const String iconoEstetica = 'Icono estética';
  static const String iconoSolarium = 'Icono solárium';
  static const String reloj = 'Reloj';
  static const String check = 'Check';
  static const String realizado = 'Check redondo';
  static const String pendiente = 'Pendiente';
  static const String rechazado = 'Rechazado';
  static const String ajustes = 'Ajustes';
}

const Map<String, IconData> listaIconos = {
  NombreIconos.inicio: Icons.cottage_outlined,
  NombreIconos.personal: Icons.person_outline,
  NombreIconos.clientes: Icons.badge_outlined,
  NombreIconos.servicios: Icons.bathtub_outlined,
  NombreIconos.cobros: Icons.credit_card_outlined,
  NombreIconos.cartera: Icons.account_balance_wallet_outlined,
  NombreIconos.flechaPequenaDerecha: Icons.chevron_right,
  NombreIconos.iconoMasaje: Icons.airline_seat_flat,
  NombreIconos.iconoEstetica: Icons.face_outlined,
  NombreIconos.iconoSolarium: Icons.light_mode_outlined,
  NombreIconos.reloj: Icons.schedule_outlined,
  NombreIconos.check: Icons.check,
  NombreIconos.realizado: Icons.check_circle_outline,
  NombreIconos.pendiente: Icons.error_outline,
  NombreIconos.rechazado: Icons.close,
  NombreIconos.ajustes: Icons.settings_outlined,
};
