import 'package:flutter/material.dart';
import '/services/databasehelper.dart';
import 'screens/login_page.dart';
import 'services/preferenciasservice.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //creamos el servicio de preferencias.
  PreferenciasService preferenciasService = await PreferenciasService.crear();
  //aumentamos el número de veces que se abre la aplicación.
  preferenciasService.aumentarNumeroAperturar();

  //guardamos la fecha y hora de la última apertura.
  preferenciasService.registrarApertura();

  Databasehelper databasehelper = await Databasehelper.crear();

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
  final Databasehelper _databasehelper;

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
      valueListenable: widget._preferenciasService.temaOscuro,

      builder: (context, temaOscuro, child) {
        return ValueListenableBuilder<double>(
          valueListenable: widget._preferenciasService.tamanoLetra,

          builder: (context, tamanoLetra, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'HabitosApp',

              //colores de la aplicación en modo claro.
              theme: ThemeData(
                scaffoldBackgroundColor: Color(0xFFF5F7F2),

                colorScheme: ColorScheme.light(
                  primary: Color(0xFF72917C),
                  secondary: Color(0xFFA2BBA8),
                  surface: Color(0xFFFFFFFF),
                ),

                //colores de la barra superior.
                appBarTheme: AppBarTheme(
                  backgroundColor: Color(0xFFF5F7F2),
                  foregroundColor: Color(0xFF263D32),
                ),
              ),

              //colores de la aplicación en modo oscuro.
              darkTheme: ThemeData(
                scaffoldBackgroundColor: Color(0xFF171F1B),

                colorScheme: ColorScheme.dark(
                  primary: Color(0xFFA2BBA8),
                  secondary: Color(0xFF72917C),
                  surface: Color(0xFF28352E),
                ),

                //colores de la barra superior en modo oscuro.
                appBarTheme: AppBarTheme(
                  backgroundColor: Color(0xFF171F1B),
                  foregroundColor: Color(0xFFE9F1EA),
                ),
              ),

              //seleccionamos el tema guardado.
              themeMode: temaOscuro ? ThemeMode.dark : ThemeMode.light,

              //ahora vamos a aplicar el tamaño de la letra a TODOS los textos
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(tamanoLetra / 14)),
                  child: child!, //aquí indicamos que child no es null, poniendo el !
                );
              },

              //comprobamos si el usuario ya se ha registrado.
              home: LoginPage(preferenciasService: widget._preferenciasService,
                  databasehelper: widget._databasehelper),
            );

          },
        );
      },
    );
  }
}
