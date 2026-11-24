import 'package:flutter/material.dart';

import '../models/colores.dart';
import '../models/iconos.dart';
import '../services/preferenciasservice.dart';
import '../widgets/boton_principal.dart';

class ComoJugar extends StatefulWidget {
  ComoJugar({super.key});

  @override
  State<ComoJugar> createState() => _ComoJugarState();
}

class _ComoJugarState extends State<ComoJugar> {
  bool combinado = false;

  //combinamos las fichas del ejemplo
  void _combinar() {
    setState(() {
      combinado = true;
    });
  }

  //reiniciamos el ejemplo
  void _reiniciar() {
    setState(() {
      combinado = false;
    });
  }

  //creamos una ficha para el ejemplo
  Widget _fichaEjemplo(int valor, Map<String, Color> colores) {
    return Container(
      width: 70,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colores['$valor'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$valor', style: Theme.of(context).textTheme.titleLarge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(context),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Cómo se juega')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '¿Cuál es el objetivo?',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            SizedBox(height: 16),

            Text(
              'Combina fichas del mismo valor hasta conseguir la ficha 2048.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),

            Divider(color: colores[NombreColores.bordes]),

            SizedBox(height: 24),

            Text(
              '1. Desliza las fichas',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            SizedBox(height: 16),

            Icon(
              listaIconos[NombreIconos.deslizar],
              size: 64,
              color: colores[NombreColores.principal],
            ),

            SizedBox(height: 16),

            Text(
              'Desliza el dedo hacia arriba, abajo, izquierda o derecha para mover las fichas del tablero.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),

            Divider(color: colores[NombreColores.bordes]),

            SizedBox(height: 24),

            Text(
              '2. Combina fichas iguales',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            SizedBox(height: 16),

            Text(
              'Cuando dos fichas del mismo valor se encuentran, se fusionan en una sola con el doble de valor.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),

            GestureDetector(
              onHorizontalDragEnd: (details) {
                _combinar();
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: colores[NombreColores.superficie],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colores[NombreColores.bordes]!),
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  child: combinado
                      ? Row(
                          key: ValueKey('combinado'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [_fichaEjemplo(4, colores)],
                        )
                      : Row(
                          key: ValueKey('sinCombinar'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _fichaEjemplo(2, colores),
                            SizedBox(width: 8),
                            _fichaEjemplo(2, colores),
                          ],
                        ),
                ),
              ),
            ),

            SizedBox(height: 16),

            Text(
              combinado
                  ? '¡Has combinado las dos fichas!'
                  : 'Desliza el dedo sobre las fichas para combinarlas.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16),

            BotonPrincipal(texto: 'Repetir ejemplo', pulsar: _reiniciar),

            SizedBox(height: 24),

            Divider(color: colores[NombreColores.bordes]),

            SizedBox(height: 24),

            Text(
              '3. Consigue puntos',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            SizedBox(height: 16),

            Text(
              'Cada vez que combines dos fichas, el valor de la ficha resultante se sumará a tu puntuación.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 24),

            Divider(color: colores[NombreColores.bordes]),

            SizedBox(height: 24),

            Text(
              '4. Fin de la partida',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            SizedBox(height: 16),

            Text(
              'La partida termina cuando el tablero está lleno y no es posible realizar ninguna combinación.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
