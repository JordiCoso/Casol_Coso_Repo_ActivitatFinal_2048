//import 'package:_2048/routes.dart';
import 'package:_2048/screens/ajustes.dart';
import 'package:_2048/screens/estadisticas_page.dart';
import 'package:_2048/screens/historial_page.dart';
import 'package:_2048/screens/ranking_page.dart';
//import 'package:_2048/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/databasehelper.dart';
import 'models/colores.dart';
//import 'models/usuario.dart';
import 'services/preferenciasservice.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //creamos el servicio de preferencias.
  final PreferenciasService preferenciasService =
      await PreferenciasService.crear();

  final DatabaseHelper databasehelper = await DatabaseHelper.crear();

  //iniciamos la aplicación con el servicio de preferencias.
  runApp(
    MyApp(
      preferenciasService: preferenciasService,
      databasehelper: databasehelper,
    ),
  );
}

class MyApp extends StatefulWidget {
  //servicio que utilizamos para recuperar las preferencias.
  final PreferenciasService _preferenciasService;

  final DatabaseHelper _databasehelper;

  const MyApp({
    super.key,
    required this._preferenciasService,
    required this._databasehelper,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //la aplicacion "escucha" los cambios.
    return ValueListenableBuilder<bool>(
      valueListenable: PreferenciasService.instanciaPS.temaOscuro,

      builder: (context, temaOscuro, child) {
        final Map<String, Color> colores = obtenerEsquemaColoresActual(
          PreferenciasService.instanciaPS.obtenerTemaOscuro(),
        );
        
        return MaterialApp(
        //return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: '2048',

          theme: ThemeData(
            scaffoldBackgroundColor: colores[NombreColores.fondo],

            textTheme: TextTheme(
              titleLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 28,
                color: colores[NombreColores.textoPrincipal],
              ),
              titleMedium: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: colores[NombreColores.textoPrincipal],
              ),
              bodyMedium: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: colores[NombreColores.textoSecundario],
              ),
              labelLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: colores[NombreColores.superficie],
              ),
            ),

            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  width: 1.5,
                  color: colores[NombreColores.bordes]!,
                ),
                elevation: 10,
                minimumSize: Size.square(10),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                iconColor: colores[NombreColores.textoSecundario]!,
              ),
            ),

            checkboxTheme: CheckboxThemeData(),

            colorScheme: ColorScheme.light(
              primary: colores[NombreColores.principal]!,
              secondary: colores[NombreColores.secundario]!,
              surface: colores[NombreColores.superficie]!,
            ),
          ),

          home: PantallaAjustes(),
          /*home: PantallaPrincipal(
            preferenciasService: widget._preferenciasService,
            databasehelper: widget._databasehelper,
            usuario: Usuario(nombre: 'aa', numeroHabitos: 2),
          ),*/
          //routerConfig: router,


        );
      },
    );
  }
}
