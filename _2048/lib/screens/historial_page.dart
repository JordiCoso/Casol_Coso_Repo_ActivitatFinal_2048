import 'package:flutter/material.dart';

import '../data/partida_dao.dart';
import '../models/partida.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  final PartidaDao _partidaDao = PartidaDao();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _fichaController = TextEditingController();

  List<Partida> _partidas = [];
  int _indice = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPartidas();
  }

  //cargamos las partidas de sqlite
  Future<void> _cargarPartidas() async {
    setState(() {
      _cargando = true;
    });

    final resultado = await _partidaDao.obtenerTodasLasPartidas();

    if (!mounted) return;

    setState(() {
      _partidas = resultado;
      _indice = 0;
      _cargando = false;
    });
  }

  //filtramos las partidas por nombre de usuario
  Future<void> _filtrarPorUsuario() async {
    final nombreUsuario = _usuarioController.text.trim();

    if (nombreUsuario.isEmpty) {
      await _cargarPartidas();
      return;
    }

    setState(() {
      _cargando = true;
    });

    final resultado = await _partidaDao.obtenerPartidasUsuario(nombreUsuario);

    if (!mounted) return;

    setState(() {
      _partidas = resultado;
      _indice = 0;
      _cargando = false;
    });
  }

  //filtramos las partidas por ficha maxima
  Future<void> _filtrarPorFicha() async {
    final textoFicha = _fichaController.text.trim();

    if (textoFicha.isEmpty) {
      await _cargarPartidas();
      return;
    }

    final fichaMaxima = int.parse(textoFicha);

    setState(() {
      _cargando = true;
    });

    final resultado = await _partidaDao.obtenerPartidasPorFicha(fichaMaxima);

    if (!mounted) return;

    setState(() {
      _partidas = resultado;
      _indice = 0;
      _cargando = false;
    });
  }

  //filtramos por usuario y ficha maxima
  Future<void> _filtrarAmbos() async {
    final nombreUsuario = _usuarioController.text.trim();
    final textoFicha = _fichaController.text.trim();

    if (nombreUsuario.isEmpty || textoFicha.isEmpty) {
      return;
    }

    final fichaMaxima = int.parse(textoFicha);

    setState(() {
      _cargando = true;
    });

    final resultado = await _partidaDao.obtenerPartidasFiltradas(
      nombreUsuario,
      fichaMaxima,
    );

    if (!mounted) return;

    setState(() {
      _partidas = resultado;
      _indice = 0;
      _cargando = false;
    });
  }

  //cambiamos la partida que estamos viendo
  void _mover(int paso) {
    final nuevoIndice = _indice + paso;

    if (nuevoIndice < 0 || nuevoIndice >= _partidas.length) {
      return;
    }

    setState(() {
      _indice = nuevoIndice;
    });
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _fichaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Buscar por usuario',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 12),

              ElevatedButton(
                onPressed: _filtrarPorUsuario,
                child: Text('Buscar'),
              ),

              SizedBox(height: 12),

              TextField(
                controller: _fichaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Ficha máxima mínima',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 12),

              ElevatedButton(
                onPressed: _filtrarPorFicha,
                child: Text('Filtrar por ficha'),
              ),

              SizedBox(height: 12),

              ElevatedButton(
                onPressed: _filtrarAmbos,
                child: Text('Aplicar ambos filtros'),
              ),

              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _cargarPartidas,
                child: Text('Actualizar historial'),
              ),

              SizedBox(height: 24),

              if (_cargando) Text('Cargando partidas...'),

              if (!_cargando && _partidas.isEmpty)
                Text('No hay partidas guardadas'),

              if (!_cargando && _partidas.isNotEmpty)
                Column(
                  children: [
                    Text('Partida ${_indice + 1} de ${_partidas.length}'),

                    SizedBox(height: 24),

                    Text('Usuario: ${_partidas[_indice].usuario}'),

                    SizedBox(height: 12),

                    Text('Puntuación: ${_partidas[_indice].puntuacion}'),

                    SizedBox(height: 12),

                    Text('Ficha máxima: ${_partidas[_indice].fichaMaxima}'),

                    SizedBox(height: 12),

                    Text('Movimientos: ${_partidas[_indice].movimientos}'),

                    SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => _mover(-1),
                          child: Text('Anterior'),
                        ),
                        TextButton(
                          onPressed: () => _mover(1),
                          child: Text('Siguiente'),
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
