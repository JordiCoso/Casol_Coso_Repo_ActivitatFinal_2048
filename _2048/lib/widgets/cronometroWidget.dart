import 'dart:async';

import 'package:flutter/cupertino.dart';

class CronometroWidget extends StatefulWidget {
  int tiempoEnSegundos = 0;

  CronometroWidget({super.key, this.tiempoEnSegundos = 0});

  @override
  State<StatefulWidget> createState() => _CronometroWidgetState();
}

class _CronometroWidgetState extends State<CronometroWidget> {
  Stopwatch stopWatch = Stopwatch();
  late Timer timer;
  String tiempoPasado = '0';
  int tiempoInicial = 0;

  @override
  void initState() {
    super.initState();

    tiempoInicial = widget.tiempoEnSegundos;
    tiempoPasado = _formatearTiempo(Duration(seconds: tiempoInicial));

    stopWatch.start();

    timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      if (mounted) {
        setState(() {
          if (stopWatch.isRunning) {
            Duration tiempo =
                Duration(seconds: tiempoInicial) + stopWatch.elapsed;

            tiempoPasado = _formatearTiempo(tiempo);
            widget.tiempoEnSegundos = tiempo.inSeconds;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    stopWatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Cronometro: $tiempoPasado');
  }

  String _formatearTiempo(Duration tiempo) {
    return '${tiempo.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(tiempo.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(tiempo.inMilliseconds % 1000 ~/ 100).toString()}';
  }
}
