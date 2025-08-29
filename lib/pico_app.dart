// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/main_screen.dart';

const AdvFontOffSet = 2;

enum PtFont {
  Hourglass,
  YouSquared,
  Ubuntu_Mono,
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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: fontNotifier.value.name.replaceAll("_", " "),
          ),
          home: const MainScreen(),
        );
      },
      listenable: fontNotifier,
    );
  }
}
