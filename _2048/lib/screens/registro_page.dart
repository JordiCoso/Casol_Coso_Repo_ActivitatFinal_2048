import 'package:flutter/material.dart';
import '/services/databasehelper.dart';
import '/widgets/boton_principal.dart';
import 'package:intl/intl.dart';

import '/widgets/campo_texto_app.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  //creamos los controladores para tener los datos mientras se usa en el registro y recuperarlos cuando lo necesitemos.
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  String mensajeError = '';

  @override
  //cuando se quite la pantalla, debemos usar el dispose para librerar la informacion.
  void dispose() {
    usuarioController.dispose();
    nombreController.dispose();
    apellidoController.dispose();
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
    String email = emailController.text.trim();
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

    Databasehelper database = await Databasehelper.crear();
    //antes de registrar al uusario, comprobamos en sqflite q no exissta otro con el mismo nombre
    bool usuarioExiste = await database.existeUsuario(
      usuarioController.text.trim(),
    );

    if (usuarioExiste) {
      setState(() {
        mensajeError = 'Este nombre de usuario ya existe';
      });
      return;
    }
    //hacemos la misma comprobacion con el correo, para q no hayan dos usuarios con el mismo correo
    bool emailExiste = await database.existeEmail(emailController.text.trim());

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
    String fechaCreacion = DateFormat('dd-MM-yyyy').format(DateTime.now());

    //todos los nuevos usuarios tendran el rol de usuario. así no pueden escoger su rol
    String rol = 'usuario';

    //le pasamos los datos para poner en el usuario
    await database.insertarUsuario(
      usuarioController.text.trim(),
      nombreController.text.trim(),
      apellidoController.text.trim(),
      emailController.text.trim(),
      contrasenaController.text.trim(),
      fechaCreacion,
      rol,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Nombre', controller: nombreController),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Apellido', controller: apellidoController),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Email', controller: emailController),

            SizedBox(height: 16),

            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: contrasenaController,
              ocultarTexto: true,
            ),

            SizedBox(height: 24),

            //comprobamos si el mensaje de error tiene texto, si lo tiene muestra el mensaje de error.
            if (mensajeError.isNotEmpty)
              Text(mensajeError, style: TextStyle(color: Colors.red)),

            SizedBox(height: 24),

            BotonPrincipal(texto: 'Registrarse', pulsar: registrarUsuario),
          ],
        ),
      ),
    );
  }
}
