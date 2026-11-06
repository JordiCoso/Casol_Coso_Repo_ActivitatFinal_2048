import 'dart:ui';

class NombreColores {
  NombreColores._nollamar();

  static const String verdePrincipal = 'VerdePrincipal';
  static const String verdeSecundario = 'VerdeSecundario';
  static const String acento = 'Acento';
  static const String bordes = 'Bordes';
  static const String fondo = 'Fondo';
  static const String superficie = 'Superficie';
  static const String textoPrincipal = 'TextoPrincipal';
  static const String textoSecundario = 'TextoSecundario';
  static const String estadoExito = 'EstadoExito';
  static const String estadoAviso = 'EstadoAviso';
  static const String estadoError = 'EstadoError';
  static const String estadoSeleccion = 'EstadoSeleccion';
}

// La lista de colores el cual usaremos el enum para que se vea cual es.
const Map<String, Color> modoClaroListaColores = {
  NombreColores.verdePrincipal: Color(0xFF6B8F72), // Verde principal
  NombreColores.verdeSecundario: Color(0xFFA7C4AB), // Verde secundario
  NombreColores.acento: Color(0xFFD4A373), // Acento
  NombreColores.bordes: Color(0xFFDCE3DB), // Bordes
  NombreColores.fondo: Color(0xFFF8F6F2), // Fondo
  NombreColores.superficie: Color(0xFFFFFFFF), // Superficie
  NombreColores.textoPrincipal: Color(0xFF1F2D26), // Texto principal
  NombreColores.textoSecundario: Color(0xFF687870), // Texto secundario
  // Colores de estado
  NombreColores.estadoExito: Color(0xFF4F8A68), // Exito
  NombreColores.estadoAviso: Color(0xFFD99A45), // Aviso
  NombreColores.estadoError: Color(0xFFC9655B), // Error
  NombreColores.estadoSeleccion: Color(0xFF47634D), // Seleccion
};

const Map<String, Color> modoOscuroListaColores = {
  NombreColores.verdePrincipal: Color(0xFF8FB69A), // Verde principal
  NombreColores.verdeSecundario: Color(0xFF668B73), // Verde secundario
  NombreColores.acento: Color(0xFFD4A373), // Acento
  NombreColores.bordes: Color(0xFF405248), // Bordes
  NombreColores.fondo: Color(0xFF032D1E), // Fondo
  NombreColores.superficie: Color(0xFF26382E), // Superficie
  NombreColores.textoPrincipal: Color(0xFFF2F4F0), // Texto principal
  NombreColores.textoSecundario: Color(0xFFB3C0B6), // Texto secundario
  // Colores de estado
  NombreColores.estadoExito: Color(0xFF70B58C), // Exito
  NombreColores.estadoAviso: Color(0xFFE4AD61), // Aviso
  NombreColores.estadoError: Color(0xFFE07E75), // Error
  NombreColores.estadoSeleccion: Color(0xFFA4C9AD), // Seleccion
};
