import 'dart:async';

import 'package:flutter/cupertino.dart';

class CronometroWidget extends StatefulWidget {
  int tiempoEnSegundos = 0;

  @override
  State<StatefulWidget> createState() => _CronometroWidgetState();
}

class _CronometroWidgetState extends State<CronometroWidget> {
  Stopwatch stopWatch = Stopwatch();
  late Timer timer;
  String tiempoPasado = '0';

  @override
  void dispose() {
    timer.cancel();
    stopWatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      timer.cancel();
      return Text('Cronometro null');
    }

    stopWatch.start();
    // Create a timer that runs a callback every 100 milliseconds to update UI
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if(mounted) {
        setState(() {
        // Update elapsed time only if the stopwatch is running
        if (stopWatch.isRunning) {
          tiempoPasado = _formatearTiempo(stopWatch.elapsed);
          widget.tiempoEnSegundos = stopWatch.elapsed.inSeconds;
        }
      });
      }
    });

    return Text('Cronometro: $tiempoPasado');
  }

  String _formatearTiempo(Duration tiempo) {
    return '${tiempo.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(tiempo.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(tiempo.inMilliseconds % 1000 ~/ 100).toString()}';
  }
}
