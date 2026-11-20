class Usuario {
  final int?
  id; //es nullable pq sqflite lo genera automatico al insertar usuario
  final String usuario;
  final String fechaRegistro;
  final String email;
  final String contrasena;

  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasena,
  });

  //convertimos el usuario en un mapa para guardarlo
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'usuario': usuario,
      'fecha_registro': fechaRegistro,
      'email': email,
      'contrasena': contrasena,
    };
  }

  //convertimos los datos de la bbdd en un usuario
  static Usuario fromMap(Map<String, Object?> mapa) {
    return Usuario(
      id: mapa['id'] as int?,
      usuario: mapa['usuario'] as String,
      fechaRegistro: mapa['fecha_registro'] as String,
      email: mapa['email'] as String,
      contrasena: mapa['contrasena'] as String,
    );
  }
}
