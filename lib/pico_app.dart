// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/main_screen.dart';

class PicoApp extends StatelessWidget {
  const PicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "H: ${MediaQuery.of(context).size.height} W: ${MediaQuery.of(context).size.width}");
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF202020),
      ),
      home: const MainScreen(),
    );
  }
}
