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
  const MainScreen({super.key});

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
            // Clear command also sets the background color
            _grid.setBackground(cmd.r, cmd.g, cmd.b);
            _grid.clear();
            break;
          case ColourCmd():
            _grid.setColor(cmd.r, cmd.g, cmd.b);
            break;
          case FontCmd():
            final offset = serialHandler.isAdvance() ? AdvFontOffSet : 0;
            fontNotifier.value = PtFont.values[cmd.index + offset];
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
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PicoScreen(
              _grid,
              _grid.background,
              connected: serialHandler.isConnected(),
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
