import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  /// La instancia unica de databasehelper
  static DatabaseHelper? _databasehelper;

  ///!! SI USAS ESTO SIN HABER CREADO ANTES LA CLASE DARA ERROR !!
  static DatabaseHelper get instanciaDH {
    final instancia = _databasehelper;
    if (instancia == null) {
      throw Exception(
        'No has inicializado la clase databasehelper antes de hacer este get',
      );
    }
    return instancia;
  }

  /// La base de datos unica para uso interno.
  late final Database _baseDeDatos;

  /// permitimos que los dao accedan a la bbdd
  Database get baseDeDatos => _baseDeDatos;

  /// Constructor privado para evitar que se pueda llamar a new.
  DatabaseHelper._crear();

  /// Constructor publico singleton asegura que solo hay una instancia de esta clase.
  static FutureOr<DatabaseHelper> crear() async {
    final DatabaseHelper? instancia = _databasehelper;
    if (instancia != null) {
      return instancia;
    }

    final inicializando = DatabaseHelper._crear();

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
    final ruta = join(await getDatabasesPath(), 'game2048.db');

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
      '$columnaUsuariosId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$columnaUsuariosUsuario TEXT NOT NULL UNIQUE, '
      '$columnaUsuariosFecharegistro TEXT NOT NULL,'
      '$columnaUsuariosEmail TEXT NOT NULL, '
      '$columnaUsuariosContrasena TEXT NOT NULL) ',
    );

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaPartidas ('
      '$columnaPartidasId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnaPartidasUsuario TEXT NOT NULL,'
      '$columnaPartidasPuntuacion INTEGER NOT NULL,'
      '$columnaPartidasFichamaxima INTEGER NOT NULL,'
      '$columnaPartidasMovimientos INTEGER NOT NULL,'
      '$columnaPartidasDuracionsegundos INTEGER NOT NULL,'
      '$columnaPartidasFecha TEXT NOT NULL)',
    );

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaGuardado ('
      '$columnaGuardadoId INTEGER PRIMARY KEY, '
      '$columnaGuardadoTablero  TEXT NOT NULL, '
      '$columnaGuardadoPuntuacion  INTEGER NOT NULL, '
      '$columnaGuardadoMovimientos  INTEGER NOT NULL, '
      '$columnaGuardadoSegundostranscurridos  INTEGER NOT NULL) ',
    );

    await packDeInstrucciones.commit();
  }

  //creamos la funcion para insertar el usuario
  /* Future<int> insertarUsuario(
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
  }*/
}
