import 'package:_2048/models/colores.dart';
import 'package:_2048/models/iconos.dart';
import 'package:_2048/services/preferenciasservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/partida_dao.dart';
import '../data/usuario_dao.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final PartidaDao _partidaDao = PartidaDao();
  final UsuarioDao _usuarioDao = UsuarioDao();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _fichaController = TextEditingController();

  List<Partida> _partidas = [];
  bool _cargando = true;
  bool _error = false;
  String _ultimoFiltro = 'todos';

  @override
  void initState() {
    super.initState();
    _cargarPartidas();
  }

  //cargamos las partidas de sqlite
  Future<void> _cargarPartidas() async {
    setState(() {
      _ultimoFiltro = 'todos';
      _cargando = true;
      _error = false;
    });

    try {
      final resultado = await _partidaDao.obtenerTodasLasPartidas();

      if (!mounted) return;

      setState(() {
        _ultimoFiltro = 'todos';
        _partidas = resultado;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _ultimoFiltro = 'todos';
        _cargando = false;
        _error = true;
      });
    }
  }

  //filtramos las partidas por nombre de usuario
  Future<void> _filtrarPorUsuario() async {
    final nombreUsuario = _usuarioController.text.trim();

    if (nombreUsuario.isEmpty) {
      await _cargarPartidas();
      return;
    }

    setState(() {
      _ultimoFiltro = 'usuario';
      _cargando = true;
      _error = false;
    });

    try {
      //buscamos el usuario mediante su nombre
      final usuario = await _usuarioDao.obtenerUsuarioPorNombre(nombreUsuario);

      if (usuario == null) {
        if (!mounted) return;

        setState(() {
          _partidas = [];
          _cargando = false;
        });

        return;
      }

      final resultado = await _partidaDao.obtenerPartidasUsuario(usuario.id!);

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

  //filtramos las partidas por ficha maxima
  Future<void> _filtrarPorFicha() async {
    final textoFicha = _fichaController.text.trim();

    if (textoFicha.isEmpty) {
      await _cargarPartidas();
      return;
    }

    final fichaMaxima = int.tryParse(
      textoFicha,
    ); //con esto devuelve null cuando el texto no es num valido

    if (fichaMaxima == null) {
      return;
    }

    setState(() {
      _ultimoFiltro = 'ficha';
      _cargando = true;
      _error = false;
    });

    try {
      final resultado = await _partidaDao.obtenerPartidasPorFicha(fichaMaxima);

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

  //filtramos por usuario y ficha maxima
  Future<void> _filtrarAmbos() async {
    final nombreUsuario = _usuarioController.text.trim();
    final textoFicha = _fichaController.text.trim();

    if (nombreUsuario.isEmpty || textoFicha.isEmpty) {
      return;
    }

    final fichaMaxima = int.tryParse(textoFicha);

    if (fichaMaxima == null) {
      return;
    }

    setState(() {
      _ultimoFiltro = 'ambos';
      _cargando = true;
      _error = false;
    });

    try {
      //buscamos el usuario para obtener su id
      final usuario = await _usuarioDao.obtenerUsuarioPorNombre(nombreUsuario);

      if (usuario == null) {
        if (!mounted) return;

        setState(() {
          _partidas = [];
          _cargando = false;
        });

        return;
      }

      final resultado = await _partidaDao.obtenerPartidasFiltradas(
        usuario.id!,
        fichaMaxima,
      );
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

  //repetimos el ultimo filtro
  Future<void> _reintentar() async {
    if (_ultimoFiltro == 'usuario') {
      await _filtrarPorUsuario();
    } else if (_ultimoFiltro == 'ficha') {
      await _filtrarPorFicha();
    } else if (_ultimoFiltro == 'ambos') {
      await _filtrarAmbos();
    } else {
      await _cargarPartidas();
    }
  }

  //abrimos el detalle y comprobamos si se ha eliminado
  Future<void> _abrirDetalles(int idPartida) async {
    context.goNamed(
      Rutas.detallePartida,
      pathParameters: {Rutas.parametroDetallePartidaID: idPartida.toString()},
    );
  }

  //eliminamos la partida y actualizamos el historial
  Future<void> _eliminarPartida(int idPartida) async {
    try {
      await _partidaDao.eliminarPartida(idPartida);

      if (!mounted) return;

      _reintentar();
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error al eliminar'),
          content: Text('No se ha podido eliminar la partida'),
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

  //confirmacion
  void _confirmarEliminarPartida(int idPartida) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        titulo: 'Eliminar partida',
        mensaje: '¿Seguro que quieres eliminar esta partida?',
        textoConfirmar: 'Eliminar',
        textoCancelar: 'Cancelar',
        onConfirmar: () {
          Navigator.pop(context);
          _eliminarPartida(idPartida);
        },
        onCancelar: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  //preguntamos si queremos eliminar la partida deslizada
  Future<bool> _confirmarDeslizamiento() async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        titulo: 'Eliminar partida',
        mensaje: '¿Seguro que quieres eliminar esta partida?',
        textoConfirmar: 'Eliminar',
        textoCancelar: 'Cancelar',
        onConfirmar: () {
          Navigator.pop(context, true);
        },
        onCancelar: () {
          Navigator.pop(context, false);
        },
      ),
    );

    return resultado == true;
  }

  //mostramos las opciones de la partida seleccionada
  void _mostrarOpcionesPartida(int idPartida) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones de partida'),
        content: const Text('¿Qué quieres hacer con esta partida?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _abrirDetalles(idPartida);
            },
            child: const Text('Ver detalles'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmarEliminarPartida(idPartida);
            },
            child: const Text('Eliminar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _fichaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: colores[NombreColores.textoPrincipal],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: colores[NombreColores.principal],
        backgroundColor: colores[NombreColores.superficie],
        onRefresh: _reintentar,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                TextField(
                  controller: _usuarioController,
                  style: TextStyle(
                    color: colores[NombreColores.textoPrincipal],
                  ),
                  decoration: InputDecoration(
                    labelText: 'Buscar por usuario',
                    labelStyle: TextStyle(
                      color: colores[NombreColores.textoSecundario],
                    ),
                    filled: true,
                    fillColor: colores[NombreColores.superficie],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colores[NombreColores.bordes]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colores[NombreColores.principal]!,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colores[NombreColores.principal],
                    fixedSize: Size(300, 50),
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _filtrarPorUsuario,
                  child: Text(
                    'Buscar',
                    style: TextStyle(color: colores[NombreColores.fondo]),
                  ),
                ),

                SizedBox(height: 12),

                TextField(
                  controller: _fichaController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: colores[NombreColores.textoPrincipal],
                  ),
                  decoration: InputDecoration(
                    labelText: 'Buscar por ficha',
                    labelStyle: TextStyle(
                      color: colores[NombreColores.textoSecundario],
                    ),
                    filled: true,
                    fillColor: colores[NombreColores.superficie],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colores[NombreColores.bordes]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colores[NombreColores.principal]!,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colores[NombreColores.principal],
                    fixedSize: Size(300, 50),
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _filtrarPorFicha,
                  child: Text(
                    'Filtrar por ficha',
                    style: TextStyle(color: colores[NombreColores.fondo]),
                  ),
                ),

                SizedBox(height: 12),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colores[NombreColores.principal],
                    fixedSize: Size(300, 50),
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _filtrarAmbos,
                  child: Text(
                    'Aplicar ambos filtros',
                    style: TextStyle(color: colores[NombreColores.fondo]),
                  ),
                ),

                SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colores[NombreColores.principal],
                    fixedSize: Size(300, 50),
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _cargarPartidas,
                  child: Text(
                    'Actualizar historial',
                    style: TextStyle(color: colores[NombreColores.fondo]),
                  ),
                ),

                SizedBox(height: 24),

                AsyncDataView(
                  cargando: _cargando,
                  error: _error,
                  onReintentar: _reintentar,
                ),

                if (!_cargando && !_error && _partidas.isEmpty)
                  EmptyStateView(
                    mensaje: 'No hay partidas guardadas',
                    icono: listaIconos[NombreIconos.sinPartidas]!,
                    color: colores[NombreColores.textoSecundario]!,
                  ),

                if (!_cargando && !_error && _partidas.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        'Total de partidas: ${_partidas.length}',
                        style: TextStyle(
                          color: colores[NombreColores.textoPrincipal],
                        ),
                      ),

                      const SizedBox(height: 16),

                      for (final partida in _partidas)
                        Dismissible(
                          key: ValueKey(partida.id),
                          direction: DismissDirection.endToStart,

                          background: Container(
                            color: colores[NombreColores.estadoError],
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Eliminar',
                              style: TextStyle(
                                color: colores[NombreColores.textoPrincipal],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          confirmDismiss: (direction) async {
                            final confirmar = await _confirmarDeslizamiento();

                            if (!confirmar) {
                              return false;
                            }

                            if (partida.id == null) {
                              return false;
                            }

                            try {
                              await _partidaDao.eliminarPartida(partida.id!);

                              if (!mounted) return false;

                              setState(() {
                                _partidas.remove(partida);
                              });

                              _reintentar();
                              return false;
                            } catch (e) {
                              if (!mounted) return false;

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error al eliminar'),
                                  content: Text(
                                    'No se ha podido eliminar la partida.',
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

                              return false;
                            }
                          },

                          child: PartidaListItem(
                            partida: partida,
                            onPulsar: () {
                              if (partida.id != null) {
                                _abrirDetalles(partida.id!);
                              }
                            },
                            onPulsacionLarga: () {
                              if (partida.id != null) {
                                _mostrarOpcionesPartida(partida.id!);
                              }
                            },
                          ),
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
