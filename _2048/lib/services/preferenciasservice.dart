import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../models/habito.dart';
import '../models/usuario.dart';

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
    var inicializando = PreferenciasService._crear();

    inicializando._preferencias = await SharedPreferences.getInstance();

    inicializando.temaOscuro.value = inicializando.obtenerTemaOscuro();

    inicializando.tamanoLetra.value = inicializando.obtenerTamanoLetra();

    return inicializando;
  }

  bool? getPrimerInicio() {
    return _preferencias.getBool("primerInicio");
  }

  void setPrimerInicio(bool valor) {
    _preferencias.setBool("primerInicio", valor);
  }

  void guardarUsuario(Usuario usuario) {
    _preferencias.setString("usuario", usuario.nombre);
    _preferencias.setInt("numeroHabitos", usuario.numeroHabitos);
  }

  Usuario cargarUsuario() {
    String nombre = _preferencias.getString("usuario") ?? '';
    int numeroHabitos = _preferencias.getInt("numeroHabitos") ?? 0;
    Usuario usuario = Usuario(nombre: nombre, numeroHabitos: numeroHabitos);

    return usuario;
  }

  /// Identificador de fecha guardada.
  static const String nombreDatoFecha = 'ultimaApertura';

  void guardarUltimaApertura(String fecha) {
    _preferencias.setString(nombreDatoFecha, fecha);
  }

  String? obtenerUltimaApertura() {
    return _preferencias.getString(nombreDatoFecha);
  }

  /// Identificador de numero de aperturas.
  static const String nombreDatoAperturas = 'numeroAperturas';

  void guardarNumeroAperturas(int numero) {
    _preferencias.setInt(nombreDatoAperturas, numero);
  }

  int obtenerNumeroAperturas() {
    return _preferencias.getInt(nombreDatoAperturas) ?? 0;
  }

  void aumentarNumeroAperturar() {
    int aperturas = obtenerNumeroAperturas();

    aperturas += 1;

    guardarNumeroAperturas(aperturas);
  }

  void registrarApertura() {
    DateTime ahora = DateTime.now();

    DateFormat formato = DateFormat('dd-MM-yyyy HH:mm:ss');

    String fecha = formato.format(ahora);

    guardarUltimaApertura(fecha);
  }

  /// Identificador de tema oscuro.
  static const String nombreDatoTema = 'temaOscuro';

  void guardarTemaOscuro(bool nuevoTema) {
    _preferencias.setBool(nombreDatoTema, nuevoTema);

    // Se avisa a las pantallas de que se ha cambiado el tema.
    temaOscuro.value = nuevoTema;
  }

  bool obtenerTemaOscuro() {
    return _preferencias.getBool(nombreDatoTema) ?? false;
  }

  /// Identificador de tamaño de letra.
  static const String nombreDatoTamanoLetra = 'tamanoLetra';

  void guardarTamanoLetra(double nuevoTamano) {
    _preferencias.setDouble(nombreDatoTamanoLetra, nuevoTamano);

    // Se avisa a la app que se ha cambiado el tamaño.
    tamanoLetra.value = nuevoTamano;
  }

  double obtenerTamanoLetra() {
    return _preferencias.getDouble(nombreDatoTamanoLetra) ?? 14;
  }

  /// Identificador de ocultar hábitos.
  static const String nombreDatoOcultar = 'ocultarCompletados';

  void guardarOcultarCompletados(bool ocultar) {
    _preferencias.setBool(nombreDatoOcultar, ocultar);
  }

  bool obtenerOcultarCompletados() {
    return _preferencias.getBool(nombreDatoOcultar) ?? false;
  }

  Future<void> borrarTodosLosDatos() async {
    await _preferencias.clear();
  }

  /// Guarda el modo oscuro y avisa cuando cambia.
  ValueNotifier<bool> temaOscuro = ValueNotifier<bool>(false);

  /// Guarda el tamaño de letra y avisa cuando cambia.
  ValueNotifier<double> tamanoLetra = ValueNotifier<double>(14);
}
