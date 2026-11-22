import 'package:_2048/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/usuario_dao.dart';
import '../models/usuario.dart';
import '../services/contrasena_service.dart';
import '/services/preferenciasservice.dart';

import '../models/colores.dart';
import '/widgets/boton_principal.dart';

import '/widgets/campo_texto_app.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  //utilizamos el dao para consultar los usuarios
  final UsuarioDao _usuarioDao = UsuarioDao();

  //utilizamos el servicio para proteger las contraseñas
  final ContrasenaService _contrasenaService = ContrasenaService();

  //creamos los controladores para tener los datos mientras se usa en el registro y recuperarlos cuando lo necesitemos.
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  String mensajeError = '';
  bool registrando = false;

  @override
  //cuando se quite la pantalla, debemos usar el dispose para librerar la informacion.
  void dispose() {
    usuarioController.dispose();
    emailController.dispose();
    contrasenaController.dispose();

    super.dispose();
  }

  //comprobamos que no esté vacío, para todos los campos con el controller.
  //Usamos el setState para mostrar el mensaje de error si el campo queda vacío.
  Future<void> registrarUsuario() async {
    if (registrando) return;

    final String nombreUsuario = usuarioController.text.trim();
    final String email = emailController.text.trim();
    final String contrasena = contrasenaController.text;

    if (nombreUsuario.isEmpty) {
      setState(() {
        mensajeError = 'El usuario no puede estar vacío';
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        mensajeError = 'El email no puede estar vacío';
      });
      return;
    }

    //comprobacion del correo
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        mensajeError = 'El email no es válido';
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
      registrando = true;
    });

    try {
      final bool usuarioExiste = await _usuarioDao.existeUsuario(nombreUsuario);

      if (!mounted) return;

      if (usuarioExiste) {
        setState(() {
          mensajeError = 'Este nombre de usuario ya está registrado';
          registrando = false;
        });
        return;
      }

      final bool emailExiste = await _usuarioDao.existeEmail(email);

      if (!mounted) return;

      if (emailExiste) {
        setState(() {
          mensajeError = 'Este correo ya existe';
          registrando = false;
        });
        return;
      }

      //obtenemos la fecha del registro en formato iso 8601
      final String fechaRegistro = DateTime.now().toIso8601String();

      //generamos el hash de la contraseña
      final String hash = await _contrasenaService.generarHash(
        contrasena,
      );

      if (!mounted) return;

      final Usuario nuevoUsuario = Usuario(
        usuario: nombreUsuario,
        email: email,
        contrasena: hash,
        fechaRegistro: fechaRegistro,
      );

      //guardamos el user en la bbdd
      await _usuarioDao.insertarUsuario(nuevoUsuario);

      if (!mounted) return;

      context.goNamed(Rutas.login);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensajeError = 'No se ha podido completar el registro';
      });
    } finally {
      if (mounted) {
        setState(() {
          registrando = false;
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
      appBar: AppBar(title: Text('Registro')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController),

            const SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Email', controller: emailController),

            const SizedBox(height: 16),

            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: contrasenaController,
              ocultarTexto: true,
            ),

            const SizedBox(height: 24),

            //comprobamos si el mensaje de error tiene texto, si lo tiene muestra el mensaje de error.
            if (mensajeError.isNotEmpty)
              Text(
                mensajeError,
                style: TextStyle(color: colores[NombreColores.estadoError]),
              ),

            const SizedBox(height: 24),

            BotonPrincipal(
              texto: registrando ? 'Registrando...' : 'Registrarse',
              pulsar: registrarUsuario,
            ),
          ],
        ),
      ),
    );
  }
}
