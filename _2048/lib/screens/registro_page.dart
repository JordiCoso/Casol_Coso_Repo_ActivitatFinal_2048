import 'package:flutter/material.dart';

import '../data/usuario_dao.dart';
import '../models/usuario.dart';
import '../services/contrasena_service.dart';
import '/services/preferenciasservice.dart';

import '../models/colores.dart';
import '../data/databasehelper.dart';
import '/widgets/boton_principal.dart';

import '/widgets/campo_texto_app.dart';

class RegistroPage extends StatefulWidget {
  final Databasehelper _databasehelper;
  final PreferenciasService _preferenciasService;

  const RegistroPage({
    super.key,
    required this._databasehelper,
    required this._preferenciasService,
  });

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  //utilizamos el dao para las consultas de usuarios
  late final UsuarioDao _usuarioDao;

  //utilizamos el servicio para proteger las contraseñas
  final ContrasenaService _contrasenaService = ContrasenaService();

  @override
  void initState() {
    super.initState();
    _usuarioDao = UsuarioDao(widget._databasehelper);
  }

  //creamos los controladores para tener los datos mientras se usa en el registro y recuperarlos cuando lo necesitemos.
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  String mensajeError = '';

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
    if (usuarioController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'El usuario no puede estar vacío';
      });
      return;
    }

    //comprobamos si el nombre de usuario ya está registrado
    final bool usuarioExiste = await _usuarioDao.existeUsuario(
      usuarioController.text.trim(),
    );

    if (!mounted) return;

    if (usuarioExiste) {
      setState(() {
        mensajeError = 'Este nombre de usuario ya está registrado';
      });
      return;
    }

    if (emailController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'El email no puede estar vacío';
      });
      return;
    }

    //comprobamos que el correo tenga @ para que sea válido.
    final String email = emailController.text.trim();
    if (!email.contains('@')) {
      setState(() {
        mensajeError = 'El email no es válido';
      });
      return;
    }

    if (contrasenaController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'La contraseña no puede estar vacía';
      });
      return;
    }

    //comprobamos si el email ya existe en la bbdd
    final bool emailExiste = await _usuarioDao.existeEmail(email);

    if (!mounted) return;

    if (emailExiste) {
      setState(() {
        mensajeError = 'Este correo ya existe';
      });
      return;
    }

    //con este setState, si todos los campos son válidos, no saldrá nada.
    setState(() {
      mensajeError = '';
    });

    //obtenemos la fecha del registro en formato iso 8601
    final String fechaRegistro = DateTime.now().toIso8601String();

    //generamos el hash de la contraseña
    final String hash = await _contrasenaService.generarHash(
      contrasenaController.text,
    );

    //creamos el usuario con los datos del formulario
    final Usuario nuevoUsuario = Usuario(
      usuario: usuarioController.text.trim(),
      email: email,
      contrasena: hash,
      fechaRegistro: fechaRegistro,
    );

    //guardamos el usuario en la bbdd
    await _usuarioDao.insertarUsuario(nuevoUsuario);

    //comprobamos que el usuario se haya guardado correctamente
    bool usuarioGuardado = await _usuarioDao.existeEmail(email);

    print('Usuario guardado: $usuarioGuardado');

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colores = obtenerEsquemaColoresActual(
      widget._preferenciasService.obtenerTemaOscuro(),
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

            BotonPrincipal(texto: 'Registrarse', pulsar: registrarUsuario),
          ],
        ),
      ),
    );
  }
}
