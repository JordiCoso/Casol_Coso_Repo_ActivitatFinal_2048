import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Databasehelper {
  /// La instancia unica de databasehelper
  static Databasehelper? _databasehelper;

  /// La base de datos unica para uso interno.
  late final Database _baseDeDatos;

  /// Constructor privado para evitar que se pueda llamar a new.
  Databasehelper._crear();

  /// Constructor publico singleton asegura que solo hay una instancia de esta clase.
  static Future<Databasehelper> crear() async {
    if (_databasehelper != null) {
      return await Future.value(_databasehelper);
    }

    final inicializando = Databasehelper._crear();

    inicializando._baseDeDatos = await inicializando._getInstanciaBD;

    _databasehelper = inicializando;

    return inicializando;
  }

  /// NO llamar, solo usa para hacer el singleton.
  Database? _comprobacionInstanciaBD;

  /// NO llamar, solo se usa en el constructor [crear].
  Future<Database> get _getInstanciaBD async {
    if (_comprobacionInstanciaBD != null) {
      return _comprobacionInstanciaBD!;
    }

    _comprobacionInstanciaBD = await _generarBase();
    return _comprobacionInstanciaBD!;
  }

  /// Crea el archivo y la primera vez usa [creacionBaseDatos] para
  /// ejecutar los SQL de creación de tablas.
  Future<Database> _generarBase() async {
    final ruta = join(await getDatabasesPath(), 'vaporbooking.db');

    final baseCreada = await openDatabase(
      ruta,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: creacionBaseDatos,
    );

    return baseCreada;
  }

  // Claves en variables para juntarlas y evitar errores

  static const tablaUsuarios =
      'usuarios'; // TODO usuarios que se han registrado en la app

  static const columnaUsuariosId = 'id'; // TODO Identificador de la partida
  static const columnaUsuariosUsuario = 'usuario'; // TODO Nombre del jugador
  static const columnaUsuariosFecharegistro =
      'fecha_registro'; // TODO FECHA Y HORA ISO 8601
  static const columnaUsuariosEmail =
      'email'; // TODO Formato correcto y validado ‘@’
  static const columnaUsuariosContrasena = 'contrasena'; // TODO ENCRIPTADA

  static const tablaPartidas =
      'partidas'; // TODO historial de partidas terminadas

  static const columnaPartidasId = 'id'; // TODO Identificador de la partida
  static const columnaPartidasUsuario = 'usuario'; // TODO Nombre del jugador
  static const columnaPartidasPuntuacion = 'puntuacion'; // TODO Puntos finales
  static const columnaPartidasFichamaxima = 'ficha_maxima'; // TODO Valor de la ficha más alta conseguida (2, 4, ..., 2048)
  static const columnaPartidasMovimientos =
      'movimientos'; // TODO Número de movimientos realizados
  static const columnaPartidasDuracionsegundos =
      'duracion_segundos'; // TODO Duración de la partida
  static const columnaPartidasFecha =
      'fecha'; // TODO Fecha y hora en formato ISO 8601

  static const tablaGuardado = 'partida_guardada'; // TODO estado de la partida en curso, para poder continuar al reabrir la aplicación

  static const columnaGuardadoId =
      'id'; // TODO Siempre 1 (solo existe una partida en curso)
  static const columnaGuardadoTablero = 'tablero'; // TODO Estado del tablero serializado (por ejemplo, JSON con la lista de 16 valores)
  static const columnaGuardadoPuntuacion =
      'puntuacion'; // TODO Puntuación actual
  static const columnaGuardadoMovimientos =
      'movimientos'; // TODO Movimientos realizados hasta el momento
  static const columnaGuardadoSegundostranscurridos =
      'segundos_transcurridos'; // TODO Tiempo acumulado

  Future<void> creacionBaseDatos(Database db, int version) async {
    final Batch packDeInstrucciones = db.batch();

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaUsuarios ('
      '$columnaUsuariosEmail TEXT NOT NULL PRIMARY KEY, '
      '$columnaUsuariosNombre TEXT NOT NULL, '
      '$columnaUsuariosApellidos TEXT NOT NULL,'
      '$columnaUsuariosTelefono TEXT NOT NULL, '
      '$columnaUsuariosContrasena TEXT NOT NULL, '
      '$columnaUsuariosFechacreacion TEXT NOT NULL, '
      '$columnaUsuariosRol TEXT NOT NULL,'
      '$columnaUsuariosPuntos INTEGER NOT NULL)',
    );

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaEmpleados ('
      '$columnaEmpleadosId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnaEmpleadosNombre TEXT NOT NULL,'
      '$columnaEmpleadosApellidos TEXT NOT NULL,'
      '$columnaEmpleadosEmail TEXT NOT NULL UNIQUE,'
      '$columnaEmpleadosTelefono TEXT NOT NULL,'
      '$columnaEmpleadosEspecialidad TEXT NOT NULL,'
      '$columnaEmpleadosPuesto TEXT)',
    );

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaServicios ('
      '$columnaServiciosId INTEGER NOT NULL PRIMARY KEY, '
      '$columnaServiciosNombre TEXT NOT NULL, '
      '$columnaServiciosDescripcion TEXT NOT NULL, '
      '$columnaServiciosPrecio INTEGER NOT NULL, '
      '$columnaServiciosDuracion INTEGER NOT NULL, '
      '$columnaServiciosValoracionPuntos INTEGER NOT NULL)',
    );

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaCitas ('
      '$columnaCitasId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnaCitasReservaId INTEGER NOT NULL,'
      '$columnaCitasFecha TEXT NOT NULL,'
      '$columnaCitasHora TEXT NOT NULL,'
      '$columnaCitasHora_Fin TEXT NOT NULL,'
      '$columnaCitasEstado TEXT NOT NULL,'
      '$columnaCitasObservaciones TEXT,'
      '$columnaCitasUsuariosClienteEmailFK TEXT NOT NULL,'
      '$columnaCitasServiciosIdFK INTEGER NOT NULL,'
      'FOREIGN KEY ($columnaCitasUsuariosClienteEmailFK) REFERENCES $tablaUsuarios($columnaUsuariosEmail),'
      'FOREIGN KEY ($columnaCitasServiciosIdFK) REFERENCES $tablaServicios($columnaServiciosId))',
    );

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaTiquets ('
      '$columnaTiquetsId INTEGER NOT NULL PRIMARY KEY, '
      '$columnaTiquetsFecha TEXT NOT NULL, '
      '$columnaTiquetsTotalPrecio INTEGER NOT NULL, '
      '$columnaTiquetsEstado TEXT NOT NULL, '
      '$columnaTiquetsUsuariosEmailFK TEXT NOT NULL, '
      'FOREIGN KEY ($columnaTiquetsUsuariosEmailFK) REFERENCES $tablaUsuarios($columnaUsuariosEmail))',
    );

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaTiquetsservicios ('
      '$columnaTiquetsserviciosCantidad INTEGER NOT NULL, '
      '$columnaTiquetsserviciosTiquetsIdFK INTEGER NOT NULL, '
      '$columnaTiquetsserviciosServiciosIdFK INTEGER NOT NULL, '
      'PRIMARY KEY ($columnaTiquetsserviciosTiquetsIdFK, $columnaTiquetsserviciosServiciosIdFK), '
      'FOREIGN KEY ($columnaTiquetsserviciosTiquetsIdFK) REFERENCES $tablaTiquets($columnaTiquetsId), '
      'FOREIGN KEY ($columnaTiquetsserviciosServiciosIdFK) REFERENCES $tablaServicios($columnaServiciosId))',
    );

    //creamos el admin de prueba
    /* packDeInstrucciones.insert(tablaUsuarios, {
      columnaUsuariosNombre: 'Administrador',
      columnaUsuariosApellidos: 'Prueba',
      columnaUsuariosEmail: 'admin@gmail.com',
      columnaUsuariosContrasena: 'admin123',
      columnaUsuariosFechacreacion: DateTime.now().toString(),
      columnaUsuariosRol: 'admin',
    })*/

    packDeInstrucciones.insert(tablaServicios, {
      columnaServiciosId: 1,
      columnaServiciosNombre: 'Masaje',
      columnaServiciosDescripcion:
          'Masaje corporal para aliviar tensiones y favorecer la relajación.',
      columnaServiciosPrecio: 45,
      columnaServiciosDuracion: 60,
      columnaServiciosValoracionPuntos: 20,
    });

    packDeInstrucciones.insert(tablaServicios, {
      columnaServiciosId: 2,
      columnaServiciosNombre: 'Estética',
      columnaServiciosDescripcion:
          'Limpieza e hidratación facial para cuidar y revitalizar la piel.',
      columnaServiciosPrecio: 35,
      columnaServiciosDuracion: 45,
      columnaServiciosValoracionPuntos: 15,
    });

    packDeInstrucciones.insert(tablaServicios, {
      columnaServiciosId: 3,
      columnaServiciosNombre: 'Solarium',
      columnaServiciosDescripcion:
          'Sesión de solárium para conseguir un bronceado uniforme y natural.',
      columnaServiciosPrecio: 25,
      columnaServiciosDuracion: 20,
      columnaServiciosValoracionPuntos: 10,
    });

    await packDeInstrucciones.commit();
  }

  //creamos la funcion para insertar el usuario
  Future<int> insertarUsuario(
    String email,
    String nombre,
    String apellidos,
    String telefono,
    String contrasena,
    String fechaCreacion,
    String rol,
  ) async {
    final int resultado = await _baseDeDatos.insert(tablaUsuarios, {
      columnaUsuariosEmail: email,
      columnaUsuariosNombre: nombre,
      columnaUsuariosApellidos: apellidos,
      columnaUsuariosTelefono: telefono,
      columnaUsuariosContrasena: contrasena,
      columnaUsuariosFechacreacion: fechaCreacion,
      columnaUsuariosRol: rol,
      columnaUsuariosPuntos: 0,
    });

    return resultado;
  }

  //comprobamos si existe el correo o no de usuario
  Future<bool> existeEmail(String email) async {
    final resultado = await _baseDeDatos.query(
      tablaUsuarios,
      where: '$columnaUsuariosEmail = ?',
      whereArgs: [email],
    );

    return resultado.isNotEmpty;
  }

  //comprobamos si existe el correo o no de empleado
  Future<bool> existeEmailEmpleado(String email) async {
    final resultado = await _baseDeDatos.query(
      tablaEmpleados,
      where: '$columnaEmpleadosEmail = ?',
      whereArgs: [email],
    );

    return resultado.isNotEmpty;
  }

  //obtenemos todos los usuarios para el administrador
  Future<List<Map<String, Object?>>> obtenerUsuarios() async {
    final resultado = await _baseDeDatos.query(tablaUsuarios);

    return resultado;
  }

  //eliminamos un usuario de la bbdd, para q el admin pueda eliminarlos bien
  Future<int> eliminarUsuario(String email) async {
    final resultado = await _baseDeDatos.delete(
      tablaUsuarios,
      where: '$columnaUsuariosEmail = ?',
      whereArgs: [email],
    );
    return resultado;
  }

  //se actualizan los datos cuando un admin modifica el usuario
  Future<int> actualizarUsuario(
    String email,
    String nombre,
    String apellidos,
    String rol,
  ) async {
    final resultado = await _baseDeDatos.update(
      tablaUsuarios,
      {
        columnaUsuariosEmail: email,
        columnaUsuariosNombre: nombre,
        columnaUsuariosApellidos: apellidos,
        columnaUsuariosRol: rol,
      },
      where: '$columnaUsuariosEmail = ?',
      whereArgs: [email],
    );

    return resultado;
  }

  //comrprobamos si el email y la contrtaseña son correctos
  Future<Map<String, Object?>?> iniciarSesion(
    String nombre,
    String contrasena,
  ) async {
    final resultado = await _baseDeDatos.query(
      tablaUsuarios,
      where: '$columnaUsuariosNombre = ? AND $columnaUsuariosContrasena = ?',
      whereArgs: [nombre, contrasena],
    );

    for (Map<String, Object?> fila in resultado) {
      return fila;
    }

    return null;
  }

  Future<int> insertarEmpleado(
    String nombre,
    String apellidos,
    String email,
    String telefono,
    String especialidad,
  ) async {
    final int resultado = await _baseDeDatos.insert(tablaEmpleados, {
      columnaEmpleadosNombre: nombre,
      columnaEmpleadosApellidos: apellidos,
      columnaEmpleadosEmail: email,
      columnaEmpleadosTelefono: telefono,
      columnaEmpleadosEspecialidad: especialidad,
    });

    return resultado;
  }

  //obtenemos los empleados para mostrarlos en el admin
  Future<List<Map<String, Object?>>> obtenerEmpleado() async {
    final resultado = await _baseDeDatos.query(tablaEmpleados);

    return resultado;
  }

  //actualizamos los datos de un empleado
  Future<int> actualizarEmpleado(
    int id,
    String nombre,
    String apellidos,
    String email,
    String telefono,
    String especialidad,
  ) async {
    final resultado = await _baseDeDatos.update(
      tablaEmpleados,
      {
        columnaEmpleadosNombre: nombre,
        columnaEmpleadosApellidos: apellidos,
        columnaEmpleadosEmail: email,
        columnaEmpleadosTelefono: telefono,
        columnaEmpleadosEspecialidad: especialidad,
      },
      where: '$columnaEmpleadosId = ?',
      whereArgs: [id],
    );

    return resultado;
  }

  //obtenemos las citas de un cliente mediante su correo
  Future<List<Map<String, Object?>>> obtenerCitasCliente(String email) async {
    final resultado = await _baseDeDatos.query(
      tablaCitas,
      where: '$columnaCitasUsuariosClienteEmailFK = ?',
      whereArgs: [email],
    );

    return resultado;
  }

  //obtenemos todas las citas para el admin
  Future<List<Map<String, Object?>>> obtenerTodasCitas() async {
    final resultado = await _baseDeDatos.query(
      tablaCitas,
      orderBy: '$columnaCitasId DESC',
    );

    return resultado;
  }

  //insertamos una nueva cita en la base de datos
  Future<void> insertarCita(
    String fecha,
    String hora,
    String horaFin,
    String estado,
    String observaciones,
    String emailCliente,
    int idServicio,
    int idReserva,
  ) async {
    await _baseDeDatos.insert(tablaCitas, {
      columnaCitasFecha: fecha,
      columnaCitasHora: hora,
      columnaCitasHora_Fin: horaFin,
      columnaCitasEstado: estado,
      columnaCitasObservaciones: observaciones,
      columnaCitasUsuariosClienteEmailFK: emailCliente,
      columnaCitasServiciosIdFK: idServicio,
      columnaCitasReservaId: idReserva,
    });
  }

  //todos los servicios reservados juntos tendrán el mismo id
  Future<int> obtenerSiguienteIdReserva() async {
    final resultado = await _baseDeDatos.query(
      tablaCitas,
      orderBy: '$columnaCitasReservaId DESC',
    );

    //si no existen reservas aun, empezamos por 1
    if (resultado.isEmpty) {
      return 1;
    }

    int ultimoId = resultado[0][columnaCitasReservaId] as int;

    return ultimoId + 1;
  }

  //actualizamos el estado de una cita
  Future<void> actualizarEstadoCita(int idCita, String estado) async {
    await _baseDeDatos.update(
      tablaCitas,
      {columnaCitasEstado: estado},
      where: '$columnaCitasId = ?',
      whereArgs: [idCita],
    );
  }

  //obtenemos un servicio mediante su id
  Future<Map<String, Object?>?> obtenerServicioPorId(int id) async {
    final resultado = await _baseDeDatos.query(
      tablaServicios,
      where: '$columnaServiciosId = ?',
      whereArgs: [id],
    );

    if (resultado.isNotEmpty) {
      return resultado[0];
    }

    return null;
  }

  Future<void> cancelarReserva(int idReserva) async {
    await _baseDeDatos.update(
      tablaCitas,
      {columnaCitasEstado: 'Cancelada'},
      where: '$columnaCitasReservaId = ?',
      whereArgs: [idReserva],
    );
  }

  Future<List<Map<String, Object?>>> obtenerTiquets() async {
    final resultado = await _baseDeDatos.query(
      tablaTiquets,
      orderBy: '$columnaTiquetsId DESC',
    );

    return resultado;
  }

  //para que el admin pueda cambiar el estado del tiquet
  Future<void> actualizarEstadoTiquet(int idTiquet, String estado) async {
    await _baseDeDatos.update(
      tablaTiquets,
      {columnaTiquetsEstado: estado},
      where: '$columnaTiquetsId = ?',
      whereArgs: [idTiquet],
    );
  }

  //insertamos un nuevo tiquet y devolvemos su id
  Future<int> insertarTiquet(
    String fecha,
    int totalPrecio,
    String estado,
    String emailCliente,
  ) async {
    final int resultado = await _baseDeDatos.insert(tablaTiquets, {
      columnaTiquetsFecha: fecha,
      columnaTiquetsTotalPrecio: totalPrecio,
      columnaTiquetsEstado: estado,
      columnaTiquetsUsuariosEmailFK: emailCliente,
    });

    return resultado;
  }

  //relacionamos un tiquet con un servicio
  Future<void> insertarTiquetServicio(
    int idTiquet,
    int idServicio,
    int cantidad,
  ) async {
    await _baseDeDatos.insert(tablaTiquetsservicios, {
      columnaTiquetsserviciosTiquetsIdFK: idTiquet,
      columnaTiquetsserviciosServiciosIdFK: idServicio,
      columnaTiquetsserviciosCantidad: cantidad,
    });
  }

  //obtenemos los servicios relacionados con un tiquet
  Future<List<Map<String, Object?>>> obtenerServiciosTiquet(
    int idTiquet,
  ) async {
    final resultado = await _baseDeDatos.query(
      tablaTiquetsservicios,
      where: '$columnaTiquetsserviciosTiquetsIdFK = ?',
      whereArgs: [idTiquet],
    );

    return resultado;
  }

  //obtenemos los datos de un cliente por su email
  Future<Map<String, Object?>?> obtenerUsuarioPorEmail(String email) async {
    final resultado = await _baseDeDatos.query(
      tablaUsuarios,
      where: '$columnaUsuariosEmail = ?',
      whereArgs: [email],
    );

    if (resultado.isNotEmpty) {
      return resultado[0];
    }

    return null;
  }
}
