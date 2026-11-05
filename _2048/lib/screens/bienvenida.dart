import 'package:flutter/material.dart';
import '/services/databasehelper.dart';

import '/models/usuario.dart';
import 'habitos_page.dart';
import '../services/preferenciasservice.dart';

class Bienvenida extends StatefulWidget {
  // Nos pasan el servicio.
  final PreferenciasService _preferenciasService;
  final Databasehelper _databasehelper;

  const Bienvenida({
    super.key,
    required this._preferenciasService,
    required this._databasehelper,
  });

  @override
  State<Bienvenida> createState() => _BienvenidaState();
}

class _BienvenidaState extends State<Bienvenida> {
  final _nombreController = TextEditingController();
  final _numeroController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  // Usamos este valor para evitar que pasen sin datos validos
  bool _validoAvanzar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido a HabitosApp')),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              onChanged: _validarInput,
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: 'Escribe tu nombre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: _validarInput,
              controller: _numeroController,
              decoration: InputDecoration(
                labelText: 'Numero habitos',
                hintText: 'Escribe numero de hàbitos diarios',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validoAvanzar ? _botonContinuar : null,
              child: const Text('Iniciar'),
            ),
          ],
        ),
      ),
    );
  }

  void _botonContinuar() {
    String nombre = _nombreController.text.trim();
    /* Este parse parece peligroso,
     * pero si llegas a esta funcion ya ha sido comprobado que es valido.
     */
    int numberoHabitos = int.parse(_numeroController.text.trim());

    final Usuario usuario = Usuario(
      nombre: nombre,
      numeroHabitos: numberoHabitos,
    );

    widget._preferenciasService.guardarUsuario(usuario);

    // Despues de guardar el usuario finalmente pasamos a la siguiente pagina.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Principal(
          preferenciasService: widget._preferenciasService,
          databasehelper: widget._databasehelper,
          usuario: usuario,
        ),
      ),
    );
  }

  /* Esto se ejecuta cada vez que cambia el texto.
   * No necesitamos el string que nos pasa OnChanged
   * asi que _ significa que es una variable no usada
   * (gracias Garry's Mod por hacerme aprender lua)
   * en dart es mas un placeholder que algo no usado pero me sirve.
   */
  void _validarInput(_) {
    // Asumimos que no es valido avanzar hasta que se demuestre lo contrario.
    _validoAvanzar = false;
    if (_comprobarNombre()) {
      if (_comprobarNumeroHabitos()) _validoAvanzar = true;
    }

    setState(() {}); // Actualizar cada vez que hay un cambio.
  }

  bool _comprobarNombre() {
    String? nombre = _nombreController.text.trim();
    // Si despues de limpiar el texto no queda nada no es valido.
    return nombre == '' ? false : true;
  }

  bool _comprobarNumeroHabitos() {
    // Si sale un error es que no es valido.
    try {
      int numero = int.parse(_numeroController.text.trim());
      // Si sobrevive el parse miramos que sea mayor que 0 habitos
      if (numero > 0) return true;
    } on FormatException {
      return false;
    }
    // No se como se podria saltar el try pero por si acaso asumo que esta mal.
    return false;
  }
}
