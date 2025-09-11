// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:picotracker_client/command_builder.dart';
import 'package:picotracker_client/serialportinterface.dart';

import 'commands.dart';
import 'pico_app.dart';
import 'widgets/pico_screen.dart';

// just simple global for now
late final SerialPortHandler serialHandler;

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
  final cmdBuilder = CmdBuilder();
  final List<Command> _commands = [];

  StreamSubscription? usbUdevStream;

  @override
  void initState() {
    super.initState();
    serialHandler = SerialPortHandler(cmdBuilder);

    cmdBuilder.commands.listen((cmd) {
      setState(() {
        if (cmd is ClearCmd) {
          _commands.clear();
        }
        if (cmd is FontCmd) {
          final offset = serialHandler.isAdvance() ? AdvFontOffSet : 0;
          fontNotifier.value = PtFont.values[cmd.index + offset];
        }
        _commands.add(cmd);
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
              _commands,
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
