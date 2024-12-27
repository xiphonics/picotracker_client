// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:picotracker_client/command_builder.dart';
import 'package:picotracker_client/picotracker/screen_char_grid.dart';
import 'package:picotracker_client/serialportinterface.dart';

import 'commands.dart';
import 'pico_app.dart';
import 'widgets/pico_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var availablePorts = <String>[];
  int keymask = 0;
  StreamSubscription? subscription;
  StreamSubscription? cmdStreamSubscription;
  final _grid = ScreenCharGrid();
  final cmdBuilder = CmdBuilder();
  late final SerialPortHandler serialHandler;

  StreamSubscription? usbUdevStream;

  @override
  void initState() {
    super.initState();
    serialHandler = SerialPortHandler(cmdBuilder);

    cmdBuilder.commands.listen((cmd) {
      setState(() {
        switch (cmd) {
          case DrawCmd():
            _grid.setChar((x: cmd.x, y: cmd.y), cmd.char, cmd.invert);
            break;
          case ClearCmd():
            _grid.clear();
            break;
          case ColourCmd():
            _grid.setColor(cmd.r, cmd.g, cmd.b);
            break;
          case FontCmd():
            fontNotifier.value = PtFont.values[cmd.index];
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
    cmdStreamSubscription?.cancel();
    usbUdevStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print("connected: ${serialHandler.isConnected}");
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PicoScreen(
              _grid,
              _grid.background,
            ),
            Visibility(
              visible: !serialHandler.isConnected(),
              child: Positioned(
                left: MediaQuery.of(context).size.width / 4,
                top: MediaQuery.of(context).size.height / 4,
                child: MaterialButton(
                  color: const Color.fromARGB(255, 35, 13, 73),
                  child: const Padding(
                    padding: EdgeInsets.all(38.0),
                    child: Text(
                      "Connect",
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 50,
                      ),
                    ),
                  ),
                  onPressed: () {
                    serialHandler.chooseSerialDevice();
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
