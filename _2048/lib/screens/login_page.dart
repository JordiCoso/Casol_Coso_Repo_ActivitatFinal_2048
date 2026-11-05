import 'package:flutter/material.dart';
import '/screens/habitos_page.dart';
import '/screens/registro_page.dart';
import '/services/databasehelper.dart';
import '/services/preferenciasservice.dart';
import '/widgets/boton_principal.dart';
import '/widgets/campo_texto_app.dart';

import '../models/usuario.dart';

class LoginPage extends StatefulWidget {
  final PreferenciasService _preferenciasService;
  final Databasehelper _databasehelper;

  const LoginPage({
    super.key,
    required PreferenciasService preferenciasService,
    required Databasehelper databasehelper,
  }) : _preferenciasService = preferenciasService,
       _databasehelper = databasehelper;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

    //consultamos en sqflite si el usuario y la contraseña coinciden
    Map<String, Object?>? datosUsuario = await widget._databasehelper
        .iniciarSesion(
          usuarioController.text.trim(),
          contrasenaController.text.trim(),
        );

    if (!mounted) return;

    //si no se encuentra el usuario, mostraremos un mensaje de error
    if (datosUsuario == null) {
      setState(() {
        mensajeError = 'Usuario o contraseña incorrectos';
      });
      return;
    }
    setState(() {
      mensajeError = '';
    });

    //cogemos el nombre y rol desde sqflite
    Usuario usuario = Usuario(
      nombre: datosUsuario[Databasehelper.columnaUsuariosUsuario] as String,
      numeroHabitos: 1,
      rol: datosUsuario[Databasehelper.columnaUsuariosRol] as String,
    );

    //si los datos coinciden, abrimos ya la pantalla principal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Principal(
          preferenciasService: widget._preferenciasService,
          databasehelper: widget._databasehelper,
          usuario: usuario,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CampoTextoApp(etiqueta: 'Usuario', controller: usuarioController),

            SizedBox(height: 16),

            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: contrasenaController,
              ocultarTexto: true,
            ),
            SizedBox(height: 24),

            //mostramos mensaje error por si hay alguno
            if (mensajeError.isNotEmpty)
              Text(mensajeError, style: TextStyle(color: Colors.red)),

            SizedBox(height: 24),

            BotonPrincipal(texto: 'Iniciar sesión', pulsar: iniciarSesion),

            SizedBox(height: 16),

            //si el usuario no tiene cuent, le damos la opcion de reigstrarse
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroPage()),
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
