class Cuadrado {
  String posicion;
  final int valor;

  Cuadrado.vacio() : valor = 0, posicion = '00';

  Cuadrado({required this.posicion, required this.valor});

  void mover(String posicionNueva) {
    posicion = posicionNueva;
  }
}
