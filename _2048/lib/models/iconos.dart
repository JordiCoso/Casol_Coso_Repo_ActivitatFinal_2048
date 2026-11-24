import 'package:flutter/material.dart';

class NombreIconos {
  const NombreIconos._nollamar();

  static const String inicio = 'Inicio';
  static const String flechaPequenaDerecha = 'Flecha';
  static const String reloj = 'Reloj';
  static const String check = 'Check';
  static const String ajustes = 'Ajustes';
  static const String puntuacionObtenida = 'Puntuación obtenida';
  static const String fichaMaxima = 'Ficha máxima';
  static const String movimientos = 'Movimientos';
  static const String duracion = 'Duración';
  static const String totalPartidas = 'Total partidas';
  static const String puntuacionMedia = 'Puntuación media';
  static const String ranking = 'Ranking';
  static const String primerPuesto = 'Primer puesto';
  static const String sinPartidas = 'Sin partidas';
  static const String estadisticas = 'Estadísticas';
  static const String paleta = 'Paleta';
  static const String papelera = 'Papelera';
  static const String historial = 'Historial';
  static const String comoJugar = 'Como jugar';
  static const String deslizar = 'Deslizar';
}

const Map<String, IconData> listaIconos = {
  NombreIconos.inicio: Icons.cottage_outlined,
  NombreIconos.flechaPequenaDerecha: Icons.chevron_right,
  NombreIconos.reloj: Icons.schedule_outlined,
  NombreIconos.check: Icons.check,
  NombreIconos.ajustes: Icons.settings_outlined,
  NombreIconos.puntuacionObtenida: Icons.star_outline,
  NombreIconos.fichaMaxima: Icons.grid_view_outlined,
  NombreIconos.movimientos: Icons.swipe_outlined,
  NombreIconos.duracion: Icons.timer_outlined,
  NombreIconos.totalPartidas: Icons.sports_esports_outlined,
  NombreIconos.puntuacionMedia: Icons.bar_chart_outlined,
  NombreIconos.ranking: Icons.emoji_events_outlined,
  NombreIconos.primerPuesto: Icons.military_tech_outlined,
  NombreIconos.sinPartidas: Icons.search_off_outlined,
  NombreIconos.estadisticas: Icons.scoreboard_outlined,
  NombreIconos.paleta: Icons.palette_outlined,
  NombreIconos.papelera: Icons.delete_outline_outlined,
  NombreIconos.historial: Icons.history,
  NombreIconos.comoJugar: Icons.help_outline,
  NombreIconos.deslizar: Icons.swipe_outlined,
};
