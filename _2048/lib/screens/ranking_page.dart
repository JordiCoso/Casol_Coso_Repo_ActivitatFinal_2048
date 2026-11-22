import 'package:_2048/models/iconos.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/partida_dao.dart';
import '../models/colores.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../services/preferenciasservice.dart';
import '../widgets/async_data_view.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final PartidaDao _partidaDao = PartidaDao();

  List<Partida> _partidas = [];
  bool _cargando = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cargarRanking();
  }

  //cargamos las mejores partidas de sqflite
  Future<void> _cargarRanking() async {
    setState(() {
      _cargando = true;
      _error = false;
    });

    try {
      final resultado = await _partidaDao.obtenerRanking();

      if (!mounted) return;

      setState(() {
        _partidas = resultado;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = true;
      });
    }
  }

  //abrimos los detalles de la partida seleccionada
  void _abrirDetalles(int idPartida) {
    context.goNamed(
      Rutas.detallePartida,
      pathParameters: {Rutas.parametroDetallePartidaID: idPartida.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              listaIconos[NombreIconos.ranking],
              color: colores[NombreColores.principal],
            ),
            const SizedBox(width: 8),
            const Text('Ranking'),
          ],
        ),
      ),

      body: RefreshIndicator(
        color: colores[NombreColores.principal],
        backgroundColor: colores[NombreColores.superficie],
        onRefresh: _cargarRanking,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Las 10 mejores partidas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              AsyncDataView(
                cargando: _cargando,
                error: _error,
                onReintentar: _cargarRanking,
              ),

              if (!_cargando && !_error && _partidas.isEmpty)
                EmptyStateView(
                  mensaje: 'Todavía no hay partidas en el ranking',
                  icono: listaIconos[NombreIconos.sinPartidas]!,
                  color: colores[NombreColores.textoSecundario]!,
                ),

              if (!_cargando && !_error && _partidas.isNotEmpty)
                Column(
                  children: [
                    for (int i = 0; i < _partidas.length; i++)
                      Row(
                        children: [
                          if (i == 0)
                            Icon(
                              listaIconos[NombreIconos.primerPuesto],
                              color: colores[NombreColores.estadoAviso],
                              size: 32,
                            ),

                          if (i != 0)
                            Text(
                              '${i + 1}º',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: PartidaListItem(
                              partida: _partidas[i],
                              onPulsar: () {
                                if (_partidas[i].id != null) {
                                  _abrirDetalles(_partidas[i].id!);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
