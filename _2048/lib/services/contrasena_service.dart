import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class ContrasenaService {
  //configuramos argon2id para proteger las contraseñas
  final Argon2id _algoritmo = Argon2id(
    //usamos estos valores pq son los minimos q recomienda OWASP
    /*
    Use Argon2id with a minimum configuration of 19 MiB of memory, an iteration count of 2, and 1 degree of parallelism.
    El calculo segun la documentacion oficial de dart, usando 10000 de memory es: 10 000 x 1kB block = 10 MB.
     */
    memory: 19456,
    parallelism: 1,
    iterations: 2,
    hashLength: 32,
  );

  //generamos el hash de una contraseña nueva
  Future<String> generarHash(String contrasena) async {
    final random = Random.secure();

    //generamos una sal aleatoria de 16 bytes
    final sal = List<int>.generate(16, (i) => random.nextInt(256));

    //generamos el hash con la contraseña y la sal
    final clave = await _algoritmo.deriveKeyFromPassword(
      password: contrasena,
      nonce: sal,
    );

    final hash = await clave.extractBytes();

    //guardamos la sal y el hash juntos
    return '${base64Encode(sal)}:${base64Encode(hash)}';
  }

  //comprobamos si la contraseña introducida es correcta
  Future<bool> comprobarContrasena(
    String contrasena,
    String contrasenaGuardada,
  ) async {
    //separamos la sal y el hash guardados
    final partes = contrasenaGuardada.split(':');

    if (partes.length != 2) {
      return false;
    }

    final sal = base64Decode(partes[0]);
    final hashGuardado = base64Decode(partes[1]);

    //generamos el hash con la misma sal del registro
    final clave = await _algoritmo.deriveKeyFromPassword(
      password: contrasena,
      nonce: sal,
    );

    final hashNuevo = await clave.extractBytes();

    //comprobamos que tengan la misma longitud
    if (hashNuevo.length != hashGuardado.length) {
      return false;
    }

    //comparamos los hashes byte a byte
    int diferencia = 0;

    for (int i = 0; i < hashNuevo.length; i++) {
      //comparamos los bytes y guardamos si hay alguna diferencia
      diferencia |= hashNuevo[i] ^ hashGuardado[i];
    }

    return diferencia == 0;
  }
}
