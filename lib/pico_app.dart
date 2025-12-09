// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/main_screen.dart';

const AdvFontOffSet = 3;

enum PtFont {
  Hourglass,
  YouSquared,
  Wide,
  Ubuntu_Mono,
}

final fontNotifier = ValueNotifier<PtFont>(PtFont.Hourglass);

extension PtFontX on PtFont {
  String get fontFamily {
    // Default to the declared font family name (spaces not underscores)
    if (this == PtFont.Wide) return 'Hourglass';
    return name.replaceAll("_", " ");
  }
}

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
            fontFamily: fontNotifier.value.fontFamily,
          ),
          home: const MainScreen(),
        );
      },
      listenable: fontNotifier,
    );
  }
}
