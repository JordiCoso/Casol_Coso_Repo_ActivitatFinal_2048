import 'package:flutter/material.dart';
import '/screens/administracion_page.dart';
import '/widgets/tarjeta_habito.dart';

import '../services/databasehelper.dart';
import '../services/preferenciasservice.dart';
import '../models/habito.dart';
import '../models/usuario.dart';
import 'ajustes.dart';
import 'estadisticas_page.dart';
import 'editar_habitos_page.dart';
import 'login_page.dart';

class Principal extends StatefulWidget {
  // Nos pasan usuario y preferencias service
  final PreferenciasService _preferenciasService;
  final Databasehelper _databasehelper;
  final Usuario _usuario;

  const Principal({
    super.key,
    required this._preferenciasService,
    required this._databasehelper,
    required this._usuario,
  });

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  List<Habito> listaHabitos = [];

  @override
  void initState() {
    super.initState();
    cargarHabitos();
  }

  Future<void> cargarHabitos() async {
    listaHabitos = await widget._databasehelper.cargarHabitos(
      widget._usuario.nombre,
      'usuario',
    );

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú principal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hola ${widget._usuario.nombre}',
                style: TextStyle(fontSize: 50),
              ),
              SizedBox(height: 20),
              Text(
                listaHabitos.isNotEmpty
                    ? 'Has completado ${_contarHabitosCompletados()} de ${listaHabitos.length} habitos'
                    : 'No tienes ningún habito creado',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: listaHabitos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TarjetaHabito(
                            nombre: listaHabitos[index].nombre,
                            color: listaHabitos[index].color,
                            completado: listaHabitos[index].completado,
                            icono: listaHabitos[index].icono,
                            completar: (bool? newValue) =>
                                _completarHabito(index),
                          ),
                        ),
                        if (listaHabitos[index].completado)
                          Expanded(
                            child: Text(
                              softWrap: true,
                              '${listaHabitos[index].fechaCompletado}',
                              style: TextStyle(
                                color: listaHabitos[index].color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _abrirGestionHabitos,
                child: const Text('Crear'),
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaAjustes(
                        preferenciasService: widget._preferenciasService,
                        databasehelper: widget._databasehelper,
                      ),
                    ),
                  );
                },
                child: Text('Ajustes'),
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaEstadisticas(
                        preferenciasService: widget._preferenciasService,
                        usuario: widget._usuario,
                      ),
                    ),
                  );
                },
                child: Text('Estadísticas'),
              ),

              SizedBox(height: 16),

              //creo el boton de cerrar sesion para hacer pruebas con el usuario admin
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        preferenciasService: widget._preferenciasService,
                        databasehelper: widget._databasehelper,
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: Text('Cerrar sesión'),
              ),

              SizedBox(height: 16),

              //boton q solo saldrá si el user es admin
              if (widget._usuario.rol == 'admin')
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdministracionPage(
                          databasehelper: widget._databasehelper,
                          usuarioActual: widget._usuario.nombre,
                        ),
                      ),
                    );
                  },
                  child: Text('Administración'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirGestionHabitos() async {
    // Esperamos a que la pagina vuelva.
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Gestiondehabitos(
          preferenciasService: widget._preferenciasService,
          databasehelper: widget._databasehelper,
          usuario: widget._usuario,
        ),
      ),
    );
    // Cuando vuelva cargamos los datos nuevos y remplazamos.
    List<Habito> habitos = await widget._databasehelper.cargarHabitos(
      widget._usuario.nombre,
      'usuario',
    );

    setState(() {
      listaHabitos = habitos;
    });
  }

  void _completarHabito(int index) async {
    /* Me parece que asignar una variable en dart asigna un puntero
     * porque si lo copiase tendria que remplazar el original que hay
     * en la lista pero funciona sin hacerlo.
     */
    Habito habito = listaHabitos[index];

    // Cuando cambia el CheckBox comprobamos a que y actualizamos pantalla.
    setState(() {
      if (habito.completado) {
        habito.completado = false;
        return;
      } else {
        habito.actualizarRacha();
        habito.fechaCompletado = DateTime.now();
        habito.completado = true;
      }
    });

    // Una vez esta hecho los cambios guardamos;
    await widget._databasehelper.guardarHabitos(listaHabitos);
  }

  int _contarHabitosCompletados() {
    int contadorCompletados = 0;

    for (Habito habito in listaHabitos) {
      if (habito.completado) contadorCompletados++;
    }
    return contadorCompletados;
  }
}
