import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:udev/udev.dart';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'command_builder.dart';

class SerialPortHandler {
  final CmdBuilder cmdBuilder;
  SerialPort? port;
  StreamSubscription? subscription;
  StreamSubscription? usbUdevStream;

  String portname = "/dev/ttyACM0";

  SerialPortHandler(this.cmdBuilder);

  void chooseSerialDevice() async {
    // for now just use hardcoded port
    try {
      SerialPort(portname).close();
      _initPort();
      _listenForUsbDevices();
    } catch (e) {
      // ignore: avoid_print
      print("could not close serial port $e");
    }
  }

  void onSerialData(var data) {
    // print("$data");

    final byteBuf = data.toDart;
    for (int i = 0; i < byteBuf.lengthInBytes; i++) {
      cmdBuilder.addByte(byteBuf[i]);
    }
  }

  void _initPort() {
    debugPrint("Init Port");
    try {
      port = SerialPort(portname);
      port!.openReadWrite();
      _listenPort();
    } catch (_) {}
  }

  Future<void> _listenPort() async {
    if (port == null) {
      debugPrint("null port can't listen");
      return;
    }
    SerialPortReader reader = SerialPortReader(port!, timeout: 20);

    subscription = reader.stream.listen((data) {
      final byteBuf = data.buffer.asByteData();
      for (int i = 0; i < byteBuf.lengthInBytes; i++) {
        cmdBuilder.addByte(byteBuf.getUint8(i));
      }
    });
  }

  void _listenForUsbDevices() {
    final context = UdevContext();
    final stream = context.monitorDevices(subsystems: ['usb']);
    usbUdevStream = stream.listen((d) {
      // print("USBevent: $d");
      // d.properties.forEach((key, value) => print("$key:$value"));
      final ttyFile = File(portname);
      if (ttyFile.existsSync() && port == null) {
        // print("found port file, so now do init");
        _initPort();
      } else {
        // print("no more port, do close");
        port?.close();
        port = null;
      }
    });
  }
}
