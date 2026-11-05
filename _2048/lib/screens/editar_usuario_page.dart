import 'package:flutter/material.dart';
import '/services/databasehelper.dart';
import '/widgets/campo_texto_app.dart';
import '/widgets/boton_principal.dart';

class EditarUsuarioPage extends StatefulWidget {
  final Databasehelper databasehelper;
  final Map<String, Object?> usuario;
  final String usuarioActual;

  const EditarUsuarioPage({
    super.key,
    required this.databasehelper,
    required this.usuario,
    required this.usuarioActual,
  });

  @override
  State<EditarUsuarioPage> createState() => _EditarUsuarioPageState();
}

class _EditarUsuarioPageState extends State<EditarUsuarioPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String rol = 'usuario';
  String mensajeError = '';

  @override
  void initState() {
    super.initState();

    //recuperamos los datos del usuario q queramos
    nombreController.text = widget.usuario[Databasehelper.columnaUsuariosNombre]
        .toString();

    apellidoController.text = widget
        .usuario[Databasehelper.columnaUsuariosApellidos]
        .toString();

    emailController.text = widget.usuario[Databasehelper.columnaUsuariosEmail]
        .toString();

    rol = widget.usuario[Databasehelper.columnaUsuariosRol].toString();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();

    super.dispose();
  }

  //comprobacion de datos
  Future<void> guardarCambios() async {
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

    if (!emailController.text.trim().contains('@')) {
      setState(() {
        mensajeError = 'El email no es válido';
      });
      return;
    }

    //mostramos el nomnbre del usuario que estamos editando
    String usuario = widget.usuario[Databasehelper.columnaUsuariosUsuario]
        .toString();

    //con esto comproamos q el correo no exista a otro user
    final usuarios = await widget.databasehelper.obtenerUsuarios();

    for (final otroUsuario in usuarios) {
      if (otroUsuario[Databasehelper.columnaUsuariosUsuario] != usuario &&
          otroUsuario[Databasehelper.columnaUsuariosEmail] ==
              emailController.text.trim()) {
        if (!mounted) return;

        setState(() {
          mensajeError = 'Este correo ya existe';
        });
        return;
      }
    }

    //el admin conectado conserva su rol
    String rolGuardar = rol;

    if (usuario == widget.usuarioActual) {
      rolGuardar = 'admin';
    }

    //guardamos los cambios ne la bbdd
    await widget.databasehelper.actualizarUsuario(
      usuario,
      nombreController.text.trim(),
      apellidoController.text.trim(),
      emailController.text.trim(),
      rolGuardar,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String usuario = widget.usuario[Databasehelper.columnaUsuariosUsuario]
        .toString();

    return Scaffold(
      appBar: AppBar(title: Text('Editar usuario')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            //mostramos q usuario estamos editando
            Text('Usuario: $usuario'),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Nombre', controller: nombreController),

            SizedBox(height: 16),

            CampoTextoApp(
              etiqueta: 'Apellidos',
              controller: apellidoController,
            ),

            SizedBox(height: 16),

            CampoTextoApp(etiqueta: 'Email', controller: emailController),

            SizedBox(height: 24),

            //así solo se pueden modificar otros roles, no el suyo propio
            if (usuario != widget.usuarioActual)
              Column(
                children: [
                  Text('Rol seleccionado: $rol'),

                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        rol = 'usuario';
                      });
                    },
                    child: Text('Usuario'),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        rol = 'admin';
                      });
                    },
                    child: Text('Administrador'),
                  ),
                ],
              ),

            if (usuario == widget.usuarioActual) Text('Rol: Administrador'),

            SizedBox(height: 24),

            //por si hay error
            if (mensajeError.isNotEmpty)
              Text(mensajeError, style: TextStyle(color: Colors.red)),

            SizedBox(height: 24),

            BotonPrincipal(texto: 'Guardar cambios', pulsar: guardarCambios),
          ],
        ),
      ),
    );
  }
}
