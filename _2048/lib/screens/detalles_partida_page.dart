import 'package:_2048/models/iconos.dart';
import 'package:_2048/widgets/async_data_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/stat_card.dart';

class DetallesPartidaPage extends StatefulWidget {
  final String idPartida;

  const DetallesPartidaPage({super.key, required this.idPartida});

  @override
  State<DetallesPartidaPage> createState() => _DetallesPartidaPageState();
}

class _DetallesPartidaPageState extends State<DetallesPartidaPage> {
  final PartidaDao _partidaDao = PartidaDao();

  Partida? _partida;
  bool _cargando = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _cargarPartida();
  }

  //cargamos la partida por su id
  Future<void> _cargarPartida() async {
    setState(() {
      _cargando = true;
      _error = false;
    });

    try {
      final id = int.parse(widget.idPartida);
      final resultado = await _partidaDao.obtenerPartidaPorId(id);

      if (!mounted) return;

      setState(() {
        _partida = resultado;
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

  //eliminamos la partida seleccionada
  Future<void> _eliminarPartida() async {
    final id = int.parse(widget.idPartida);
    await _partidaDao.eliminarPartida(id);

    if (!mounted) return;

    context.goNamed(Rutas.historial);
  }

  //confirmacion
  void _confirmarEliminacion() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        titulo: 'Eliminar partida',
        mensaje: '¿Seguro que quieres eliminar esta partida?',
        textoConfirmar: 'Eliminar',
        textoCancelar: 'Cancelar',
        onConfirmar: () {
          Navigator.pop(context);
          _eliminarPartida();
        },
        onCancelar: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de partida')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              AsyncDataView(
                cargando: _cargando,
                error: _error,
                onReintentar: _cargarPartida,
              ),

              if (!_cargando && !_error && _partida == null)
                const Text('No se ha encontrado la partida'),

              if (!_cargando && _partida != null)
                Column(
                  children: [
                    Text(
                      'Usuario: ${_partida!.usuario}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    StatCard(
                      titulo: 'Puntuación',
                      valor: '${_partida!.puntuacion}',
                      icono: listaIconos[NombreIconos.puntuacionObtenida]!,
                    ),

                    StatCard(
                      titulo: 'Ficha máxima',
                      valor: '${_partida!.fichaMaxima}',
                      icono: listaIconos[NombreIconos.fichaMaxima]!,
                    ),

                    StatCard(
                      titulo: 'Movimientos',
                      valor: '${_partida!.movimientos}',
                      icono: listaIconos[NombreIconos.movimientos]!,
                    ),

                    StatCard(
                      titulo: 'Duración',
                      valor: '${_partida!.duracionSegundos} segundos',
                      icono: listaIconos[NombreIconos.duracion]!,
                    ),

                    const SizedBox(height: 16),

                    Text('Fecha: ${_partida!.fecha}'),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _confirmarEliminacion,
                      child: const Text('Eliminar partida'),
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
