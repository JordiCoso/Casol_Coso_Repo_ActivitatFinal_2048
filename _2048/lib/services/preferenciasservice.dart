import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class PreferenciasService {
  /// La instancia unica de preferenciasService;
  static PreferenciasService? _preferenciasService;

  ///!! SI USAS ESTO SIN HABER CREADO ANTES LA CLASE DARA ERROR !!
  static PreferenciasService get instanciaPS {
    final instancia = _preferenciasService;
    if (instancia == null) {
      throw Exception(
        'No has inicializado la clase preferenciasService antes de hacer este get',
      );
    }
    return instancia;
  }

  /// Instancia de preferencias para uso interno.
  late SharedPreferences _preferencias;

  /// Constructor privado para que no se pueda llamar a new.
  PreferenciasService._crear();

  /// Constructor publico
  ///
  /// Usa el constructor [PreferenciasService._crear] para obtener el objeto
  /// donde luego podemos utilizar un await para poder esperar a definir la
  /// variable.
  /// Hay que hacer esto porque el constructor normal no puede ser async.

  static FutureOr<PreferenciasService> crear() async {
    final PreferenciasService? instancia = _preferenciasService;
    if (instancia != null) {
      return instancia;
    }

    final inicializando = PreferenciasService._crear();

    inicializando._preferencias = await SharedPreferences.getInstance();

    inicializando.temaOscuro.value = inicializando.obtenerTemaOscuro();

    _preferenciasService = inicializando;

    return inicializando;
  }

  static const String claveDatoTema = 'temaOscuro';
  static const String claveUltimoJugador = 'ultimoJugador';
  static const String claveMejorPuntuacion = 'mejorPuntuacion';

  void guardarTemaOscuro(bool nuevoTema) {
    _preferencias.setBool(claveDatoTema, nuevoTema);

    // Se avisa a las pantallas de que se ha cambiado el tema.
    temaOscuro.value = nuevoTema;
  }

  bool obtenerTemaOscuro() {
    return _preferencias.getBool(claveDatoTema) ?? false;
  }

  //guardamos el nombre del ultimo jugador
  void guardarUltimoJugador(String nombreUsuario) {
    _preferencias.setString(claveUltimoJugador, nombreUsuario);
  }

  //obtenemos el nombre del ultimo jugador
  String obtenerUltimoJugador() {
    return _preferencias.getString(claveUltimoJugador) ?? '';
  }

  //guardamos la mejor puntuacion
  void guardarMejorPuntuacion(int puntuacion) {
    int mejorPuntuacion = obtenerMejorPuntuacion();

    if (puntuacion > mejorPuntuacion) {
      _preferencias.setInt(claveMejorPuntuacion, puntuacion);
    }
  }

  //obtenemos la mejor puntuacion
  int obtenerMejorPuntuacion() {
    return _preferencias.getInt(claveMejorPuntuacion) ?? 0;
  }

  Future<void> borrarTodosLosDatos() async {
    await _preferencias.clear();
  }

  /// Guarda el modo oscuro y avisa cuando cambia.
  ValueNotifier<bool> temaOscuro = ValueNotifier<bool>(false);
}
