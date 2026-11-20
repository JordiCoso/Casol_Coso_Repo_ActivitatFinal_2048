import 'package:flutter/material.dart';

import '/services/databasehelper.dart';

import '/services/preferenciasservice.dart';
import 'login_page.dart';

class PantallaAjustes extends StatefulWidget {
  //recibimos el preferenciasService.
  final PreferenciasService preferenciasService;
  final Databasehelper databasehelper;

  const PantallaAjustes({
    super.key,
    required this.preferenciasService,
    required this.databasehelper,
  });

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState(); //creo el estado de la pantalla.
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  bool _temaOscuro = false;
  double _tamanoLetra = 14;

  //cargamos los ajustes guardados al abrir la pantalla.
  @override
  void initState() {
    super.initState();

    _temaOscuro = widget.preferenciasService.obtenerTemaOscuro();
    _tamanoLetra = widget.preferenciasService.obtenerTamanoLetra();
  }

  void _cambiarTemaOscuro(bool nuevoTema) {
    //cambia el tema.
    setState(() {
      _temaOscuro = nuevoTema;
    });

    widget.preferenciasService.guardarTemaOscuro(
      nuevoTema,
    ); //guardamos el tema.
  }

  void _cambiarTamanoLetra(double nuevoTamano) {
    //cambia el tamaño de la letra.
    setState(() {
      _tamanoLetra = nuevoTamano;
    });

    widget.preferenciasService.guardarTamanoLetra(
      nuevoTamano,
    ); //guardamos el tamaño.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajustes')),

      body: SingleChildScrollView(
        //el contenido de la pantalla.
        padding: EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes de personalización',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              'Configuración',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            //tarjeta de apariencia.
            Container(
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //título de la sección
                  Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      const SizedBox(width: 8),

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

                  //interruptor del modo oscuro.
                  SwitchListTile(
                    title: Text('Modo oscuro'),
                    subtitle: Text('Cambia a modo oscuro o modo claro'),
                    value: _temaOscuro,
                    onChanged: _cambiarTemaOscuro,
                  ),

                  Divider(),

                  Text(
                    'Tamaño de letra: ${_tamanoLetra.round()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  //barra para seleccionar el tamaño de letra.
                  Slider(
                    value: _tamanoLetra,
                    min: 10,
                    max: 26,
                    divisions: 16,
                    onChanged: _cambiarTamanoLetra,
                  ),

                  //texto de ejemplo con el tamaño seleccionado.
                  Text(
                    'Así se verá el tamaño de la letra.',
                    style: TextStyle(fontSize: _tamanoLetra),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //tarjeta de configuración de hábitos.
            Container(
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      const SizedBox(width: 8),

                      Text(
                        'Hábitos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //tarjeta para borrar los datos.
            Container(
              padding: EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),

                      const SizedBox(width: 8),

                      Text(
                        'Datos de la aplicación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  //botón para borrar todos los datos de la aplicación.
                  ElevatedButton(
                    onPressed: () async {
                      //mostraremos una confirmación para borrar los datos.
                      bool? confirmar = await showDialog<bool>(
                        //showDialog muestra una ventana encima de la pantalla.
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('¿Borrar todos los datos?'),

                            content: Text(
                              'Se eliminarán todos los datos guardados, esta acción no se puede deshacer.',
                            ),
                            actions: [
                              //si se pulsa cancelar, se cierra la ventana.
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text('Cancelar'),
                              ),

                              //si pulsa borrar, devolvemos true para borrar.
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text('Borrar'),
                              ),
                            ],
                          );
                        },
                      );

                      //si se ha cancelado la ventana no se hace nada.
                      if (confirmar != true) {
                        return;
                      }

                      //esperamos a que se borren los datos.
                      await widget.preferenciasService.borrarTodosLosDatos();

                      //se vuelve a la bienvenida y elimina las otras pantallas.
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(
                            preferenciasService: widget.preferenciasService,
                            databasehelper: widget.databasehelper,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text('Borrar todos los datos'),
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
