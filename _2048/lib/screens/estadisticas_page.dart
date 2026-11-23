import 'package:_2048/data/databasehelper.dart';
import 'package:_2048/data/usuario_dao.dart';
import 'package:_2048/models/iconos.dart';
import 'package:flutter/material.dart';

import '../data/partida_dao.dart';
import '../models/colores.dart';
import '../services/preferenciasservice.dart';
import '../widgets/async_data_view.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/stat_card.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final PartidaDao _partidaDao = PartidaDao();
  final UsuarioDao _usuarioDao = UsuarioDao();

  List<Map<String, Object?>> _estadisticasJugadores = [];
  Map<String, Object?> _estadisticasUsuario = {};
  Map<String, Object?> _estadisticas = {};
  bool _busquedaRealizada = false;
  bool _cargando = true;
  bool _error = false;
  bool _cargandoJugadores = true;
  bool _errorJugadores = false;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
    _cargarEstadisticasJugadores();
  }

  //cargamos las estadisticas globales de sqflite
  Future<void> _cargarEstadisticas() async {
    setState(() {
      _cargando = true;
      _error = false;
    });

    try {
      final resultado = await _partidaDao.obtenerEstadisticasGlobales();

      if (!mounted) return;

      setState(() {
        _estadisticas = resultado;
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

  //buscamos las estadisticas del usuario
  Future<void> _buscarEstadisticasUsuario() async {
    final nombreUsuario = _usuarioController.text.trim();

    if (nombreUsuario.isEmpty) {
      return;
    }

    try {
      final usuario = await _usuarioDao.obtenerUsuarioPorNombre(nombreUsuario);
      if (usuario == null) {
        if (!mounted) return;

        setState(() {
          _estadisticasUsuario = {};
          _busquedaRealizada = true;
        });
        return;
      }

      final resultado = await _partidaDao.obtenerEstadisticasUsuario(
        usuario.id!,
      );

      if (!mounted) return;

      setState(() {
        _estadisticasUsuario = resultado;
        _busquedaRealizada = true;
      });
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
            'No se han podido obtener las estadísticas del usuario.',
          ),
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

  //cargamos las estadisticas de todos los jugadores
  Future<void> _cargarEstadisticasJugadores() async {
    setState(() {
      _cargandoJugadores = true;
      _errorJugadores = false;
    });

    try {
      final resultado = await _partidaDao.obtenerEstadisticasPorJugador();

      if (!mounted) return;

      setState(() {
        _estadisticasJugadores = resultado;
        _cargandoJugadores = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoJugadores = false;
        _errorJugadores = true;
      });
    }
  }

  //actualizamos todas las estadisticas
  Future<void> _actualizarEstadisticas() async {
    await _cargarEstadisticas();
    await _cargarEstadisticasJugadores();

    if (_busquedaRealizada) {
      await _buscarEstadisticasUsuario();
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(context),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              listaIconos[NombreIconos.estadisticas],
              color: colores[NombreColores.principal],
            ),
            const SizedBox(width: 8),
            const Text('Estadísticas'),
          ],
        ),
      ),

      body: RefreshIndicator(
        color: colores[NombreColores.principal],
        backgroundColor: colores[NombreColores.superficie],
        onRefresh: _actualizarEstadisticas,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Text(
                  'Estadísticas globales',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colores[NombreColores.textoPrincipal],
                  ),
                ),

                const SizedBox(height: 24),

                AsyncDataView(
                  cargando: _cargando,
                  error: _error,
                  onReintentar: _cargarEstadisticas,
                ),

                if (!_cargando &&
                    !_error &&
                    (_estadisticas[PartidaDao.totalPartidas] ?? 0) == 0)
                  EmptyStateView(
                    mensaje: 'Todavía no hay estadísticas disponibles',
                    icono: listaIconos[NombreIconos.sinPartidas]!,
                    color: colores[NombreColores.textoSecundario]!,
                  ),

                if (!_cargando &&
                    !_error &&
                    (_estadisticas[PartidaDao.totalPartidas] ?? 0) != 0)
                  Column(
                    children: [
                      StatCard(
                        titulo: 'Partidas jugadas',
                        valor:
                            '${_estadisticas[PartidaDao.totalPartidas] ?? 0}',
                        icono: listaIconos[NombreIconos.totalPartidas]!,
                      ),

                      StatCard(
                        titulo: 'Mejor puntuación',
                        valor:
                            '${_estadisticas[PartidaDao.mejorPuntuacion] ?? 0}',
                        icono: listaIconos[NombreIconos.puntuacionObtenida]!,
                      ),

                      StatCard(
                        titulo: 'Puntuación media',
                        valor:
                            '${_estadisticas[PartidaDao.puntuacionMedia] ?? 0}',
                        icono: listaIconos[NombreIconos.puntuacionMedia]!,
                      ),

                      StatCard(
                        titulo: 'Ficha máxima',
                        valor: '${_estadisticas[PartidaDao.mejorFicha] ?? 0}',
                        icono: listaIconos[NombreIconos.fichaMaxima]!,
                      ),

                      StatCard(
                        titulo: 'Tiempo total jugado',
                        valor:
                            '${_estadisticas[PartidaDao.tiempoTotalJugado] ?? 0} segundos',
                        icono: listaIconos[NombreIconos.duracion]!,
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                Text(
                  'Consultar estadíticas de un usuario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colores[NombreColores.textoPrincipal],
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _buscarEstadisticasUsuario,
                  child: const Text('Buscar estadísticas'),
                ),

                const SizedBox(height: 24),

                if (_busquedaRealizada)
                  if ((_estadisticasUsuario[PartidaDao.totalPartidas] ?? 0) ==
                      0)
                    EmptyStateView(
                      mensaje: 'Este usuario no tiene partidas guardadas',
                      icono: listaIconos[NombreIconos.sinPartidas]!,
                      color: colores[NombreColores.textoSecundario]!,
                    )
                  else
                    Column(
                      children: [
                        StatCard(
                          titulo: 'Partidas jugadas',
                          valor:
                              '${_estadisticasUsuario[PartidaDao.totalPartidas] ?? 0}',
                          icono: listaIconos[NombreIconos.totalPartidas]!,
                        ),

                        StatCard(
                          titulo: 'Mejor puntuación',
                          valor:
                              '${_estadisticasUsuario[PartidaDao.mejorPuntuacion] ?? 0}',
                          icono: listaIconos[NombreIconos.puntuacionObtenida]!,
                        ),

                        StatCard(
                          titulo: 'Mejor ficha',
                          valor:
                              '${_estadisticasUsuario[PartidaDao.mejorFicha] ?? 0}',
                          icono: listaIconos[NombreIconos.fichaMaxima]!,
                        ),
                      ],
                    ),

                const SizedBox(height: 32),

                Text(
                  'Estadísticas de jugadores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colores[NombreColores.textoPrincipal],
                  ),
                ),

                const SizedBox(height: 24),

                AsyncDataView(
                  cargando: _cargandoJugadores,
                  error: _errorJugadores,
                  onReintentar: _cargarEstadisticasJugadores,
                ),

                if (!_cargandoJugadores &&
                    !_errorJugadores &&
                    _estadisticasJugadores.isEmpty)
                  EmptyStateView(
                    mensaje: 'Todavía no hay jugadores con partidas',
                    icono: listaIconos[NombreIconos.sinPartidas]!,
                    color: colores[NombreColores.textoSecundario]!,
                  ),

                if (!_cargandoJugadores &&
                    !_errorJugadores &&
                    _estadisticasJugadores.isNotEmpty)
                  Column(
                    children: [
                      for (final jugador in _estadisticasJugadores)
                        Column(
                          children: [
                            Text(
                              '${jugador[DatabaseHelper.columnaPartidasUsuarioId]}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              'Partidas jugadas: ${jugador[PartidaDao.totalPartidas] ?? 0}',
                            ),

                            Text(
                              'Mejor puntuación: ${jugador[PartidaDao.mejorPuntuacion] ?? 0}',
                            ),

                            const Divider(),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
