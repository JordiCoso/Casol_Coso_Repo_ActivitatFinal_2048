import 'package:flutter/material.dart';

import '../data/usuario_dao.dart';
import '../services/contrasena_service.dart';
import '/models/colores.dart';
import '/screens/pantalla_principal.dart';

import '/screens/registro_page.dart';
import '../data/databasehelper.dart';
import '/services/preferenciasservice.dart';
import '/widgets/boton_principal.dart';
import '/widgets/campo_texto_app.dart';

import '../models/usuario.dart';

class LoginPage extends StatefulWidget {
  final PreferenciasService _preferenciasService;

  final Databasehelper _databasehelper;

  const LoginPage({
    super.key,
    required this._preferenciasService,
    required this._databasehelper,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //utilizamos el dao para consultar los usuarios
  late final UsuarioDao _usuarioDao;

  //utilizamos el servicio para comprobar las contraseñas
  final ContrasenaService _contrasenaService = ContrasenaService();

  @override
  void initState() {
    super.initState();
    _usuarioDao = UsuarioDao(widget._databasehelper);
  }

  //controllers para recuperar datos del login
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  String mensajeError = '';

  @override
  void dispose() {
    usuarioController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  //comprobamos datos
  Future<void> iniciarSesion() async {
    if (usuarioController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'El usuario no puede estar vacío';
      });
      return;
    }

    if (contrasenaController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'La contraseña no puede estar vacía';
      });
      return;
    }

    //buscamos el usuario por su nombre en la bbdd
    final Usuario? usuario = await _usuarioDao.obtenerUsuarioPorNombre(
      usuarioController.text.trim(),
    );

    if (!mounted) return;

    //comprobamos si el usuario existe
    if (usuario == null) {
      setState(() {
        mensajeError = 'Usuario o contraseña incorrectos';
      });
      return;
    }

    //comprobamos la contraseña con el hash guardado
    final bool contrasenaCorrecta = await _contrasenaService
        .comprobarContrasena(contrasenaController.text, usuario.contrasena);

    if (!mounted) return;

    //mostramos un error si la contraseña no coincide
    if (!contrasenaCorrecta) {
      setState(() {
        mensajeError = 'Usuario o contraseña incorrectos';
      });
      return;
    }

    //limpiamos el mensaje de error si el login es correcto
    setState(() {
      mensajeError = '';
    });

    //si los datos coinciden, abrimos ya la pantalla principal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPrincipal(
          preferenciasService: widget._preferenciasService,
          usuario: usuario,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      widget._preferenciasService.obtenerTemaOscuro(),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController),

            const SizedBox(height: 16),

            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: contrasenaController,
              ocultarTexto: true,
            ),
            const SizedBox(height: 24),

            //mostramos mensaje error por si hay alguno
            if (mensajeError.isNotEmpty)
              Text(
                mensajeError,
                style: TextStyle(color: colores[NombreColores.estadoError]),
              ),

            const SizedBox(height: 24),

            BotonPrincipal(texto: 'Iniciar sesión', pulsar: iniciarSesion),

            const SizedBox(height: 16),

            //si el usuario no tiene cuent, le damos la opcion de reigstrarse
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistroPage(
                      databasehelper: widget._databasehelper,
                      preferenciasService: widget._preferenciasService,
                    ),
                  ),
                );
              },
              child: Text('Regístrate si no tienes cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
