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

  static const tablaUsuarios = 'usuarios';

  static const columnaUsuariosId = 'id';
  static const columnaUsuariosUsuario = 'usuario'; // normalizacion de la tabla
  static const columnaUsuariosFecharegistro = 'fecha_registro';
  static const columnaUsuariosEmail = 'email';
  static const columnaUsuariosContrasena = 'contrasena';

  static const tablaPartidas = 'partidas';

  static const columnaPartidasId = 'id';
  static const columnaPartidasUsuarioId =
      'usuario_id'; // normalizacion de la tabla
  static const columnaPartidasPuntuacion = 'puntuacion';
  static const columnaPartidasFichamaxima = 'ficha_maxima';
  static const columnaPartidasMovimientos = 'movimientos';
  static const columnaPartidasDuracionsegundos = 'duracion_segundos';
  static const columnaPartidasFecha = 'fecha';

  static const tablaGuardado = 'partida_guardada';

  static const columnaGuardadoId =
      'id'; // Siempre 1 (solo existe una partida en curso)
  static const columnaGuardadoUsuarioId = 'usuario_id';
  static const columnaGuardadoTablero = 'tablero';
  static const columnaGuardadoPuntuacion = 'puntuacion';
  static const columnaGuardadoMovimientos = 'movimientos';
  static const columnaGuardadoSegundostranscurridos = 'segundos_transcurridos';

  Future<void> creacionBaseDatos(Database db, int version) async {
    final Batch packDeInstrucciones = db.batch();

    packDeInstrucciones.execute(
      'CREATE TABLE $tablaUsuarios ('
      '$columnaUsuariosId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$columnaUsuariosUsuario TEXT NOT NULL UNIQUE, '
      '$columnaUsuariosFecharegistro TEXT NOT NULL,'
      '$columnaUsuariosEmail TEXT NOT NULL UNIQUE, '
      '$columnaUsuariosContrasena TEXT NOT NULL) ',
    );

    packDeInstrucciones.execute(
      //normalizacion y comprobacion para q no hayan numeros negativos
      'CREATE TABLE $tablaPartidas ('
      '$columnaPartidasId INTEGER PRIMARY KEY AUTOINCREMENT,'
      '$columnaPartidasUsuarioId INTEGER NOT NULL,'
      '$columnaPartidasPuntuacion INTEGER NOT NULL CHECK ($columnaPartidasPuntuacion >= 0),'
      '$columnaPartidasFichamaxima INTEGER NOT NULL,'
      '$columnaPartidasMovimientos INTEGER NOT NULL CHECK ($columnaPartidasMovimientos >= 0),'
      '$columnaPartidasDuracionsegundos INTEGER NOT NULL CHECK ($columnaPartidasDuracionsegundos >= 0),'
      '$columnaPartidasFecha TEXT NOT NULL,'
      'FOREIGN KEY ($columnaPartidasUsuarioId) REFERENCES $tablaUsuarios($columnaUsuariosId))',
    );

    packDeInstrucciones.execute(
      //normalizacion y comprobacion para q no hayan numeros negativos
      'CREATE TABLE $tablaGuardado ('
      '$columnaGuardadoId INTEGER PRIMARY KEY CHECK ($columnaGuardadoId = 1),'
      '$columnaGuardadoUsuarioId INTEGER NOT NULL, '
      '$columnaGuardadoTablero  TEXT NOT NULL, '
      '$columnaGuardadoPuntuacion  INTEGER NOT NULL CHECK ($columnaGuardadoPuntuacion >= 0), '
      '$columnaGuardadoMovimientos  INTEGER NOT NULL CHECK ($columnaGuardadoMovimientos >= 0), '
      '$columnaGuardadoSegundostranscurridos  INTEGER NOT NULL CHECK ($columnaGuardadoSegundostranscurridos >= 0),'
      'FOREIGN KEY ($columnaGuardadoUsuarioId) REFERENCES $tablaUsuarios($columnaUsuariosId)) ',
    );

    await packDeInstrucciones.commit();
  }
}
