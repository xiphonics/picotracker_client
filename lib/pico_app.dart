// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/main_screen.dart';

enum PtFont {
  Hourglass,
  YouSquared,
}

final fontNotifier = ValueNotifier<PtFont>(PtFont.Hourglass);

class PicoApp extends StatelessWidget {
  const PicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "H: ${MediaQuery.of(context).size.height} W: ${MediaQuery.of(context).size.width}");
    return ListenableBuilder(
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'picoTracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: fontNotifier.value.name,
          ),
          home: const MainScreen(title: 'picoTracker'),
        );
      },
      listenable: fontNotifier,
    );
  }
}
