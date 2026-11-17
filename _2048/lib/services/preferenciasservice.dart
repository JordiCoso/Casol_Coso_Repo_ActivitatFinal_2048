import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class PreferenciasService {
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

  static Future<PreferenciasService> crear() async {
    final inicializando = PreferenciasService._crear();

    inicializando._preferencias = await SharedPreferences.getInstance();

    inicializando.temaOscuro.value = inicializando.obtenerTemaOscuro();

    inicializando.tamanoLetra.value = inicializando.obtenerTamanoLetra();

    return inicializando;
  }

  static const String claveDatoTema = 'temaOscuro';
  static const String claveDatoTamanoLetra = 'tamanoLetra';

  void guardarTemaOscuro(bool nuevoTema) {
    _preferencias.setBool(claveDatoTema, nuevoTema);

    // Se avisa a las pantallas de que se ha cambiado el tema.
    temaOscuro.value = nuevoTema;
  }

  bool obtenerTemaOscuro() {
    return _preferencias.getBool(claveDatoTema) ?? false;
  }

  void guardarTamanoLetra(double nuevoTamano) {
    _preferencias.setDouble(claveDatoTamanoLetra, nuevoTamano);

    // Se avisa a la app que se ha cambiado el tamaño.
    tamanoLetra.value = nuevoTamano;
  }

  double obtenerTamanoLetra() {
    return _preferencias.getDouble(claveDatoTamanoLetra) ?? 14;
  }

  Future<void> borrarTodosLosDatos() async {
    await _preferencias.clear();
  }

  /// Guarda el modo oscuro y avisa cuando cambia.
  ValueNotifier<bool> temaOscuro = ValueNotifier<bool>(false);

  /// Guarda el tamaño de letra y avisa cuando cambia.
  ValueNotifier<double> tamanoLetra = ValueNotifier<double>(14);
}
