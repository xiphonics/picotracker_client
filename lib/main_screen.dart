// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:picotracker_client/command_builder.dart';
import 'package:picotracker_client/serialportinterface.dart';

import 'commands.dart';
import 'screenshot_saver.dart';
import 'screen_constants.dart';
import 'widgets/pico_screen.dart';

// just simple global for now
late final SerialPortHandler serialHandler;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class CaptureScreenshotIntent extends Intent {
  const CaptureScreenshotIntent();
}

class _MainScreenState extends State<MainScreen> {
  var availablePorts = <String>[];
  int keymask = 0;
  StreamSubscription? subscription;
  StreamSubscription? cmdStreamSubscription;
  final cmdBuilder = CmdBuilder();
  final List<Command> _commands = [];
  bool isAdvanceMode = false;
  int currentFont = 2;
  bool isCapturing = false;
  final GlobalKey repaintBoundaryKey = GlobalKey();

  StreamSubscription? usbUdevStream;

  @override
  void initState() {
    super.initState();
    serialHandler = SerialPortHandler(cmdBuilder);
    serialHandler.onAdvanceModeChanged = (bool isAdvance) {
      setState(() {
        isAdvanceMode = isAdvance;
      });
    };

    cmdBuilder.commands.listen((cmd) {
      setState(() {
        if (cmd is ClearCmd) {
          _commands.clear();
        }
        // only switch fonts on picoTracker, not on Advance
        if (cmd is FontCmd && !isAdvanceMode) {
          currentFont = cmd.index;
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

  String two(int value) => value.toString().padLeft(2, '0');
  String buildScreenshotName(int width, int height) {
    final now = DateTime.now();
    return "picoTracker-"
      "${isAdvanceMode ? "Advance-" : ""}"
      "${now.year}"
      "${two(now.month)}"
      "${two(now.day)}"
      "${two(now.hour)}"
      "${two(now.minute)}"
      "${two(now.second)}"
      ".png";
  }

  Future<void> captureScreenshot() async {
    if (isCapturing) {
      return;
    }

    isCapturing = true;

    final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      isCapturing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture screenshot')),
      );
      return;
    }

    final targetWidth =
      isAdvanceMode ? kAdvanceScreenWidth : kScreenWidth;
    final targetHeight =
      isAdvanceMode ? kAdvanceScreenHeight : kScreenHeight;
    final ratio = min(targetWidth / boundary.size.width, targetHeight / boundary.size.height);

    final image = await boundary.toImage(pixelRatio: ratio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      isCapturing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture screenshot')),
      );
      return;
    }
    final bytes = byteData.buffer.asUint8List();
    final fileName = buildScreenshotName(targetWidth, targetHeight);
    
    await savePNG(bytes, fileName: fileName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved screenshot: $fileName')),
      );
    }
    isCapturing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true):
            CaptureScreenshotIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, meta: true, shift: true):
            CaptureScreenshotIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          CaptureScreenshotIntent: CallbackAction<CaptureScreenshotIntent>(
            onInvoke: (intent) {
              captureScreenshot();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, left: 24.0),
                    child: PicoScreen(
                      _commands,
                      connected: serialHandler.isConnected(),
                      isAdvanceMode: isAdvanceMode,
                      currentFont: currentFont,
                      repaintBoundaryKey: repaintBoundaryKey,
                    ),
                  ),
                  Visibility(
                    visible: !serialHandler.isConnected(),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isAdvanceMode = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: !isAdvanceMode ? kKey : kKeyLow,
                                    border: Border.all(
                                      color: Colors.amberAccent.withOpacity(
                                          !isAdvanceMode ? 1.0 : 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    "picoTracker",
                                    style: TextStyle(
                                      color: !isAdvanceMode
                                          ? Colors.amberAccent
                                          : Colors.grey,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isAdvanceMode = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: isAdvanceMode ? kKey : kKeyLow,
                                    border: Border.all(
                                      color: Colors.amberAccent.withOpacity(
                                          isAdvanceMode ? 1.0 : 0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    "Advance",
                                    style: TextStyle(
                                      color: isAdvanceMode
                                          ? Colors.amberAccent
                                          : Colors.grey,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MaterialButton(
                            color: kKey,
                            child: const Padding(
                              padding: EdgeInsets.all(28.0),
                              child: Text(
                                "Connect",
                                style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 40,
                                ),
                              ),
                            ),
                            onPressed: () {
                              serialHandler.chooseSerialDevice();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}