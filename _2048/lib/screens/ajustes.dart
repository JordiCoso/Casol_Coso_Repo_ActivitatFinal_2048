import 'package:_2048/data/partida_dao.dart';
import 'package:_2048/models/colores.dart';
import 'package:_2048/models/iconos.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:flutter/material.dart';

import '../widgets/barra_navegacion.dart';
import '../widgets/confirm_dialog.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final PartidaDao _partidaDao = PartidaDao();

  bool _eliminando = false;

  void _cambiarModoTema(ThemeMode nuevoTema) {
    PreferenciasService.instanciaPS.guardarModoTema(nuevoTema);

    setState(() {});
  }

  void _confirmarBorrarHistorial() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        titulo: '¿Borrar todo el historial?',
        mensaje:
            'Se eliminarán todas las partidas terminadas. '
            'Esta acción no se puede deshacer.',
        textoConfirmar: 'Borrar',
        textoCancelar: 'Cancelar',
        onCancelar: () {
          Navigator.pop(context);
        },
        onConfirmar: () {
          Navigator.pop(context);
          _borrarHistorial();
        },
      ),
    );
  }

  //eliminamos las partidas terminadas de sqflite
  Future<void> _borrarHistorial() async {
    setState(() {
      _eliminando = true;
    });

    try {
      final eliminadas = await _partidaDao.eliminarHistorial();

      if (!mounted) return;

      setState(() {
        _eliminando = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Historial eliminado'),
          content: Text('Se han eliminado $eliminadas partidas.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _eliminando = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se ha podido eliminar el historial'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(context),
    );
    return Scaffold(
      bottomNavigationBar: BarraNavegacion(indiceActual: 3),
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: colores[NombreColores.textoPrincipal],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalización',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colores[NombreColores.superficie],
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        listaIconos[NombreIconos.paleta],
                        color: colores[NombreColores.principal],
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Apariencia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Divider(),

                  //seleccionamos entre los tres modos del tema
                  RadioGroup<ThemeMode>(
                    groupValue: PreferenciasService.instanciaPS.leerModoTema(),
                    onChanged: (ThemeMode? nuevoModo) {
                      if (nuevoModo != null) {
                        _cambiarModoTema(nuevoModo);
                      }
                    },
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: Text(
                            'Modo claro',
                            style: TextStyle(
                              color: colores[NombreColores.textoPrincipal],
                            ),
                          ),
                          value: ThemeMode.light,
                          activeColor: colores[NombreColores.principal],
                        ),

                        RadioListTile<ThemeMode>(
                          title: Text(
                            'Modo oscuro',
                            style: TextStyle(
                              color: colores[NombreColores.textoPrincipal],
                            ),
                          ),
                          value: ThemeMode.dark,
                          activeColor: colores[NombreColores.principal],
                        ),

                        RadioListTile<ThemeMode>(
                          title: Text(
                            'Tema del sistema',
                            style: TextStyle(
                              color: colores[NombreColores.textoPrincipal],
                            ),
                          ),
                          value: ThemeMode.system,
                          activeColor: colores[NombreColores.principal],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Datos de las partidas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            //tarjeta para eliminar el historial
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colores[NombreColores.superficie],
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        listaIconos[NombreIconos.papelera],
                        color: colores[NombreColores.estadoError],
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Borrar historial',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colores[NombreColores.textoPrincipal],
                        ),
                      ),
                    ],
                  ),

                  Divider(),

                  Text(
                    'Elimina todas las partidas terminadas '
                    'guardadas en el historial.',
                  ),

                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: _eliminando ? null : _confirmarBorrarHistorial,
                    child: Text(
                      _eliminando
                          ? 'Eliminando...'
                          : 'Borrar todo el historial',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
