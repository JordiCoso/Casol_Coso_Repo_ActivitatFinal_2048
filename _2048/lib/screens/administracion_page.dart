import 'package:flutter/material.dart';
import '/services/databasehelper.dart';
import '/screens/registro_page.dart';
import '/screens/editar_usuario_page.dart';

import '../models/colores.dart';

import '../models/habito.dart';

class AdministracionPage extends StatefulWidget {
  final Databasehelper _databasehelper;
  final String usuarioActual;

  const AdministracionPage({
    super.key,
    required Databasehelper databasehelper,
    required this.usuarioActual,
  }) : _databasehelper = databasehelper;

  @override
  State<AdministracionPage> createState() => _AdministracionPageState();
}

class _AdministracionPageState extends State<AdministracionPage> {
  //guardamos los usuarios que obtenemos de la bbdd
  List<Map<String, Object?>> listaUsuarios = [];
  List<Habito> listaHabitos = [];
  List<Map<String, dynamic>> listaEstadisticas = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
    cargarHabitosAdmin();
    cargarEstadisticasAdmin();
  }

  //cargamos los usuarios de la bbdd
  Future<void> cargarUsuarios() async {
    final usuarios = await widget._databasehelper.obtenerUsuarios();

    if (!mounted) return;

    setState(() {
      listaUsuarios = usuarios;
    });
  }

  //arimos la pantalla de registro para crear un usuario
  Future<void> abrirRegistro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistroPage()),
    );

    if (!mounted) return;

    //actualizamos al volver
    await cargarUsuarios();
  }

  //pedimos la confirmacion antes de eliminar
  Future<void> confirmarEliminarUsuario(String usuario) async {
    //el ususario que está logueado no puede borrarse a si mismo
    if (usuario == widget.usuarioActual) {
      return;
    }

    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar usuario'),
          content: Text('¿Quieres eliminar al usuario $usuario?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await widget._databasehelper.eliminarUsuario(usuario);

      if (!mounted) return;

      //actualizo despues de borrar
      await cargarUsuarios();
    }
  }

  Future<void> abrirEditarUsuario(Map<String, Object?> usuario) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarUsuarioPage(
          databasehelper: widget._databasehelper,
          usuario: usuario,
          usuarioActual: widget.usuarioActual,
        ),
      ),
    );

    if (!mounted) return;

    await cargarUsuarios();
  }

  //recuperamos habitos
  Future<void> cargarHabitosAdmin() async {
    List<Habito> habitos = await widget._databasehelper.cargarHabitos(
      widget.usuarioActual,
      'admin',
    );

    if (!mounted) return;

    setState(() {
      listaHabitos = habitos;
    });
  }

  Future<void> confirmarEliminarHabito(Habito habito) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar hábito'),
          content: Text(
            '¿Quieres eliminar el hábito ${habito.nombre} de ${habito.nombreUsuario}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      //marcamos el habito para eliminarlo
      habito.pendingBorrarse = true;

      //reutilizamos el metodo q teniamos en sqflite
      await widget._databasehelper.guardarHabitos([habito]);

      if (!mounted) return;

      await cargarHabitosAdmin();
    }
  }

  //para cambiar el nombre del habito
  Future<void> editarHabitoAdmin(Habito habito) async {
    TextEditingController nombreController = TextEditingController(
      text: habito.nombre,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar hábito'),
          content: TextField(controller: nombreController),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nombreController.text.trim().isEmpty) {
                  return;
                }

                habito.nombre = nombreController.text.trim();

                await widget._databasehelper.guardarHabitos([habito]);

                if (!context.mounted)
                  return; //es para comprobar q el widget sigue activo
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );

    nombreController.dispose();

    if (!mounted) return;

    await cargarHabitosAdmin();
  }

  Future<void> crearHabitoAdmin(String usuario) async {
    TextEditingController nombreController = TextEditingController();

    bool? guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Crear hábito para $usuario'),
          content: TextField(
            controller: nombreController,
            decoration: InputDecoration(labelText: 'Nombre del hábito'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (nombreController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(context, true);
              },
              child: Text('Crear'),
            ),
          ],
        );
      },
    );

    if (guardar == true) {
      Habito nuevoHabito = Habito(
        0,
        nombreController.text.trim(),
        listaColores[NombreColores.verde.index],
        DateTime(0),
        nombreUsuario: usuario,
      );

      await widget._databasehelper.guardarHabitos([nuevoHabito]);

      if (mounted) {
        await cargarHabitosAdmin();
      }
    }

    nombreController.dispose();
  }

  //cargamos las estadisticas de todos los usuarios
  Future<void> cargarEstadisticasAdmin() async {
    final estadisticas = await widget._databasehelper.obtenerEstadisticas(
      widget.usuarioActual,
      true,
    );

    if (!mounted) return;

    setState(() {
      listaEstadisticas = estadisticas;
    });
  }

  Future<void> editarEstadisticasAdmin(Map<String, dynamic> estadistica) async {
    TextEditingController rachaController = TextEditingController(
      text: estadistica[Databasehelper.columnaEstadisticasRachaactual]
          .toString(),
    );

    TextEditingController diasController = TextEditingController(
      text: estadistica[Databasehelper.columnaEstadisticasDiascompletados]
          .toString(),
    );

    bool? guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar estadísticas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rachaController,
                decoration: InputDecoration(labelText: 'Racha actual'),
              ),
              TextField(
                controller: diasController,
                decoration: InputDecoration(labelText: 'Días completados'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                //el tryParse intenta convertir un texto en un numero
                int? racha = int.tryParse(rachaController.text);
                int? dias = int.tryParse(diasController.text);

                if (racha == null || dias == null || racha < 0 || dias < 0) {
                  return;
                }

                Navigator.pop(context, true);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (guardar == true) {
      int habitoId =
          estadistica[Databasehelper.columnaEstadisticasHabitoidFK] as int;

      await widget._databasehelper.actualizarEstadisticas(
        habitoId,
        int.parse(rachaController.text),
        int.parse(diasController.text),
        estadistica[Databasehelper.columnaEstadisticasFechacompletado]
            as String?,
      );

      if (mounted) {
        await cargarEstadisticasAdmin();
        await cargarHabitosAdmin();
      }
    }

    rachaController.dispose();
    diasController.dispose();
  }

  //creamos estadisticas para un habito que no tenga
  Future<void> crearEstadisticasAdmin(Habito habito) async {
    //recuperamos las estadisticas existentes
    final estadisticas = await widget._databasehelper.obtenerEstadisticas(
      widget.usuarioActual,
      true,
    );

    //comprobamos que el habito no tenga estadisticas
    for (Map<String, dynamic> estadistica in estadisticas) {
      if (estadistica[Databasehelper.columnaEstadisticasHabitoidFK] ==
          habito.identificador) {
        return;
      }
    }

    //creamos las estadisticas con valores iniciales
    await widget._databasehelper.insertarEstadisticas(
      DateTime(0).toString(),
      0,
      0,
      habito.identificador,
      habito.nombreUsuario,
    );

    if (!mounted) return;

    //actualizamos las listas
    await cargarEstadisticasAdmin();
    await cargarHabitosAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administración')),
      body: Column(
        children: [
          SizedBox(height: 16),

          ElevatedButton(
            onPressed: abrirRegistro,
            child: Text('Crear usuario'),
          ),

          SizedBox(height: 16),

          //mostramos todos los usuarios q existen
          Expanded(
            child: ListView.builder(
              itemCount: listaUsuarios.length,
              itemBuilder: (context, index) {
                String usuario =
                    listaUsuarios[index][Databasehelper.columnaUsuariosUsuario]
                        .toString();

                String rol =
                    listaUsuarios[index][Databasehelper.columnaUsuariosRol]
                        .toString();

                return Column(
                  children: [
                    //dice el rol y usuario
                    ListTile(title: Text(usuario), subtitle: Text(rol)),

                    //creo el boton para editar
                    ElevatedButton(
                      onPressed: () {
                        abrirEditarUsuario(listaUsuarios[index]);
                      },
                      child: Text('Editar usuario'),
                    ),

                    SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        crearHabitoAdmin(usuario);
                      },
                      child: Text('Crear hábito'),
                    ),

                    SizedBox(height: 10),

                    //el admin no puede eliminarse
                    if (usuario != widget.usuarioActual)
                      ElevatedButton(
                        onPressed: () {
                          confirmarEliminarUsuario(usuario);
                        },
                        child: Text('Eliminar usuario'),
                      ),

                    SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Hábitos registrados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 16),

          Text(
            'Estadísticas registradas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: listaEstadisticas.length,
              itemBuilder: (context, index) {
                final estadistica = listaEstadisticas[index];

                return Column(
                  children: [
                    Text(
                      'Usuario: ${estadistica[Databasehelper.columnaEstadisticasUsuarioFK]}',
                    ),
                    Text(
                      'Hábito ID: ${estadistica[Databasehelper.columnaEstadisticasHabitoidFK]}',
                    ),
                    Text(
                      'Racha: ${estadistica[Databasehelper.columnaEstadisticasRachaactual]}',
                    ),
                    Text(
                      'Días completados: ${estadistica[Databasehelper.columnaEstadisticasDiascompletados]}',
                    ),
                    SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: 8),

          //habitos de todos los usuarios
          Expanded(
            child: ListView.builder(
              itemCount: listaHabitos.length,
              itemBuilder: (context, index) {
                Habito habito = listaHabitos[index];

                return Column(
                  children: [
                    Text(habito.nombre),

                    Text('Usuario: ${habito.nombreUsuario}'),

                    SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: () {
                        editarHabitoAdmin(habito);
                      },
                      child: Text('Editar hábito'),
                    ),

                    SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: () {
                        confirmarEliminarHabito(habito);
                      },
                      child: Text('Eliminar hábito'),
                    ),

                    SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
