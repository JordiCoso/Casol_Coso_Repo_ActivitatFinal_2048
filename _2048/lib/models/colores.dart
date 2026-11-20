import 'dart:ui';

class NombreColores {
  const NombreColores._nollamar();

  static const String principal = 'Principal';
  static const String secundario = 'Secundario';
  static const String bordes = 'Bordes';
  static const String fondo = 'Fondo';
  static const String superficie = 'Superficie';
  static const String textoPrincipal = 'TextoPrincipal';
  static const String textoSecundario = 'TextoSecundario';
  static const String estadoExito = 'EstadoExito';
  static const String estadoAviso = 'EstadoAviso';
  static const String estadoError = 'EstadoError';
  static const String estadoSeleccion = 'EstadoSeleccion';

  static const String cuadrado2 = '2';
  static const String cuadrado4 = '4';
  static const String cuadrado8 = '8';
  static const String cuadrado16 = '16';
  static const String cuadrado32 = '32';
  static const String cuadrado64 = '64';
  static const String cuadrado128 = '128';
  static const String cuadrado256 = '256';
  static const String cuadrado512 = '512';
  static const String cuadrado1024 = '1024';
  static const String cuadrado2048 = '2048';
}

// La lista de colores el cual usaremos el enum para que se vea cual es.
const Map<String, Color> _modoClaroListaColores = {
  NombreColores.principal: Color(0xFF356F59), // Principal
  NombreColores.secundario: Color(0xFF866B91), // Secundario
  NombreColores.bordes: Color(0xFFB9CEC1), // Bordes
  NombreColores.fondo: Color(0xFFD9EDE2), // Fondo
  NombreColores.superficie: Color(0xFFEDF3EE), // Superficie
  NombreColores.textoPrincipal: Color(0xFF243630), // Texto principal
  NombreColores.textoSecundario: Color(0xFF65766E), // Texto secundario
  // Colores de estado
  NombreColores.estadoExito: Color(0xFF4F8A68), // Exito
  NombreColores.estadoAviso: Color(0xFFD99A45), // Aviso
  NombreColores.estadoError: Color(0xFFC9655B), // Error
  NombreColores.estadoSeleccion: Color(0xFFD4B5D8), // Seleccion
  // Cuadrados
  NombreColores.cuadrado2: Color(0xFFA8D88E), // 2
  NombreColores.cuadrado4: Color(0xFF75B96A), // 4
  NombreColores.cuadrado8: Color(0xFF4F9B69), // 8
  NombreColores.cuadrado16: Color(0xFF287A60), // 16
  NombreColores.cuadrado32: Color(0xFF194F46), // 32
  NombreColores.cuadrado64: Color(0xFF202C2A), // 64
  NombreColores.cuadrado128: Color(0xFF948A96), // 128
  NombreColores.cuadrado256: Color(0xFF97869A), // 256
  NombreColores.cuadrado512: Color(0xFF9A829F), // 512
  NombreColores.cuadrado1024: Color(0xFF9E7EA3), // 1024
  NombreColores.cuadrado2048: Color(0xFFA17AA8), // 2048
};

const Map<String, Color> _modoOscuroListaColores = {
  NombreColores.principal: Color(0xFFB0C49A), // Principal
  NombreColores.secundario: Color(0xFFC6A98F), // Secundario
  NombreColores.bordes: Color(0xFF68646B), // Bordes
  NombreColores.fondo: Color(0xFF39303E), // Fondo
  NombreColores.superficie: Color(0xFF48434D), // Superficie
  NombreColores.textoPrincipal: Color(0xFFF0EDE5), // Texto principal
  NombreColores.textoSecundario: Color(0xFFBDB6AE), // Texto secundario
  // Colores de estado
  NombreColores.estadoExito: Color(0xFF70B58C), // Exito
  NombreColores.estadoAviso: Color(0xFFE4AD61), // Aviso
  NombreColores.estadoError: Color(0xFFE07E75), // Error
  NombreColores.estadoSeleccion: Color(0xFFD8B76A), // Seleccion
  // Cuadrados
  NombreColores.cuadrado2: Color(0xFF899477), // 2
  NombreColores.cuadrado4: Color(0xFF99A487), // 4
  NombreColores.cuadrado8: Color(0xFFAAB497), // 8
  NombreColores.cuadrado16: Color(0xFFBBC4A8), // 16
  NombreColores.cuadrado32: Color(0xFFCCD4B9), // 32
  NombreColores.cuadrado64: Color(0xFFDEE4CD), // 64
  NombreColores.cuadrado128: Color(0xFFA9A59E), // 128
  NombreColores.cuadrado256: Color(0xFFAEA69A), // 256
  NombreColores.cuadrado512: Color(0xFFB3A795), // 512
  NombreColores.cuadrado1024: Color(0xFFB8A990), // 1024
  NombreColores.cuadrado2048: Color(0xFFBDAA8C), // 2048
};

Map<String, Color> obtenerEsquemaColoresActual(bool temaOscuro) {
  return temaOscuro ? _modoOscuroListaColores : _modoClaroListaColores;
}
