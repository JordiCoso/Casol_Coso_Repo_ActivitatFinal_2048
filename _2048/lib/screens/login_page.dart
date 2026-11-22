import 'package:_2048/services/preferenciasservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/usuario_dao.dart';
import '../routes.dart';
import '../services/contrasena_service.dart';
import '/models/colores.dart';
import '/widgets/boton_principal.dart';
import '/widgets/campo_texto_app.dart';

import '../models/usuario.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //utilizamos el dao para buscar los usuarios
  final UsuarioDao _usuarioDao = UsuarioDao();

  //utilizamos el servicio para comprobar las contraseñas
  final ContrasenaService _contrasenaService = ContrasenaService();

  //controllers para recuperar datos del login
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  String mensajeError = '';
  bool iniciandoSesion = false;

  @override
  void dispose() {
    usuarioController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  //comprobamos datos
  Future<void> iniciarSesion() async {
    if (iniciandoSesion) return;

    final String nombreUsuario = usuarioController.text.trim();
    final String contrasena = contrasenaController.text;

    if (nombreUsuario.isEmpty) {
      setState(() {
        mensajeError = 'El usuario no puede estar vacío';
      });
      return;
    }

    if (contrasena.trim().isEmpty) {
      setState(() {
        mensajeError = 'La contraseña no puede estar vacía';
      });
      return;
    }

    setState(() {
      mensajeError = '';
      iniciandoSesion = true;
    });

    try {
      final Usuario? usuario = await _usuarioDao.obtenerUsuarioPorNombre(
        nombreUsuario,
      );

      if (!mounted) return;

      if (usuario == null) {
        setState(() {
          mensajeError = 'Usuario o contraseña incorrectos';
        });
        return;
      }

      //comprobamos la contraseña con el hash almacenado
      final bool contrasenaCorrecta = await _contrasenaService
          .comprobarContrasena(contrasena, usuario.contrasena);

      if (!mounted) return;

      if (!contrasenaCorrecta) {
        setState(() {
          mensajeError = 'Usuario o contraseña incorrectos';
        });
        return;
      }
      //guardamos el ultimo jugador que ha iniciado sesion
      PreferenciasService.instanciaPS.guardarUltimoJugador(usuario.usuario);
      context.goNamed(Rutas.principal, extra: usuario);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensajeError = 'No se ha podido iniciar sesión';
      });
    } finally {
      if (mounted) {
        setState(() {
          iniciandoSesion = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      PreferenciasService.instanciaPS.obtenerTemaOscuro(),
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

            BotonPrincipal(
              texto: iniciandoSesion ? 'Iniciando sesión...' : 'Iniciar sesión',
              pulsar: iniciarSesion,
            ),

            const SizedBox(height: 16),

            //si el usuario no tiene cuent, le damos la opcion de reigstrarse
            TextButton(
              onPressed: () {
                context.goNamed(Rutas.registrar);
              },
              child: Text('Regístrate si no tienes cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
