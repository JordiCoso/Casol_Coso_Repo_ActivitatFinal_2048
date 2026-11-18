class Cuadrado {
  late ({int x, int y}) posicion;

  final int valor;

  Cuadrado.vacio() : valor = 0, posicion = (x: 0, y: 0);

  Cuadrado({required this.posicion, required this.valor});

  Cuadrado.fromBBDD(String posicion, this.valor) {
    late final int x;
    late final int y;

    try {
      x = int.parse(posicion[0]);
      y = int.parse(posicion[1]);
    } on FormatException {
      x = 0;
      y = 0;
    }

    this.posicion = (x: x, y: y);
  }

  ({String posicion, int valor}) toBBDD() {
    return (
      posicion: posicion.x.toString() + posicion.y.toString(),
      valor: valor,
    );
  }

  void mover(({int x, int y}) posicionNueva) {
    posicion = posicionNueva;
  }
}
