import 'package:flutter/material.dart';

import '/services/preferenciasservice.dart';

import '../models/colores.dart';
import '../data/databasehelper.dart';
import '/widgets/boton_principal.dart';

import 'package:intl/intl.dart';

import '/widgets/campo_texto_app.dart';

class RegistroPage extends StatefulWidget {
  final DatabaseHelper _databasehelper;
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
  //creamos los controladores para tener los datos mientras se usa en el registro y recuperarlos cuando lo necesitemos.
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  String mensajeError = '';

  @override
  //cuando se quite la pantalla, debemos usar el dispose para librerar la informacion.
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    contrasenaController.dispose();
    telefonoController.dispose();

    super.dispose();
  }

  //comprobamos que no esté vacío, para todos los campos con el controller.
  //Usamos el setState para mostrar el mensaje de error si el campo queda vacío.
  Future<void> registrarUsuario() async {
    if (nombreController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'El nombre no puede estar vacío';
      });
      return;
    }

    if (apellidoController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'El apellido no puede estar vacío';
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

    //comprobamos que el telefono no este vacio
    if (telefonoController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'El teléfono no puede estar vacío';
      });
      return;
    }

    if (contrasenaController.text.trim().isEmpty) {
      setState(() {
        mensajeError = 'La contraseña no puede estar vacía';
      });
      return;
    }

    //antes de registrar al uusario, comprobamos en sqflite q no exista otro con el mismo correo
    final bool emailExiste = await widget._databasehelper.existeEmail(
      emailController.text.trim(),
    );

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

    //obtenemos la fecha de creacion al registrar el usuario
    final String fechaCreacion = DateFormat('dd-MM-yyyy')
        .format(DateTime.now());

    //todos los nuevos usuarios tendran el rol de usuario. así no pueden escoger su rol
    final String rol = 'usuario';

    //le pasamos los datos para poner en el usuario
    await widget._databasehelper.insertarUsuario(
      emailController.text.trim(),
      nombreController.text.trim(),
      apellidoController.text.trim(),
      telefonoController.text.trim(),
      contrasenaController.text.trim(),
      fechaCreacion,
      rol,
    );

    //comprobamos que el correo se haya guardado correctamente
    bool usuarioGuardado = await widget._databasehelper.existeEmail(
      emailController.text.trim(),
    );

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
            CampoTextoApp(etiqueta: 'Nombre', controller: nombreController),

            const SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Apellido', controller: apellidoController),

            const SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Email', controller: emailController),

            const SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Teléfono', controller: telefonoController),

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
