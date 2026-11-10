import 'dart:ui';

class NombreColores {
  NombreColores._nollamar();

  static const String naranja = 'naranja';
  static const String azul = 'azul';
  static const String verde = 'verde';
}

// La lista de colores el cual usaremos el enum para que se vea cual es.
// TODO colores
const Map<String, Color> modoClaroListaColores = {
  NombreColores.naranja: Color(0xFFFFC067),
  NombreColores.azul: Color(0xFF6CCCC4),
  NombreColores.verde: Color(0xFF807B44),
};

// TODO colores
const Map<String, Color> modoOscuroListaColores = {
  NombreColores.naranja: Color(0xFFFFC067),
  NombreColores.azul: Color(0xFF6CCCC4),
  NombreColores.verde: Color(0xFF807B44),
};
