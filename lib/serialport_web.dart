// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:webserial/webserial.dart';
import 'dart:js_interop';

import 'command_builder.dart';

const PICOTRACKER_VENDOR_ID = 0x2E8A;
const PICOTRACKER_PRODUCT_ID = 0x000A;

// OpenMoko, Inc. PicoTracker Advance
const PICOTRACKERADVANCE_VENDOR_ID = 0x1D50;
const PICOTRACKERADVANCE_PRODUCT_ID = 0x6192;

bool _isAdvance = false;

class SerialPortHandler {
  final CmdBuilder cmdBuilder;
  JSSerialPort? port;

  SerialPortHandler(this.cmdBuilder);

  bool isConnected() => port?.connected.toDart ?? false;

  bool isAdvance() => _isAdvance;

  void chooseSerialDevice() async {
    try {
      // Create filter options for specific vendor ID
      final filters = [
        JSFilterObject(
          usbVendorId: PICOTRACKER_VENDOR_ID,
          usbProductId: PICOTRACKER_PRODUCT_ID,
        ),
        JSFilterObject(
          usbVendorId: PICOTRACKERADVANCE_VENDOR_ID,
          usbProductId: PICOTRACKERADVANCE_PRODUCT_ID,
        )
      ];

      port = await requestWebSerialPort(filters.toJS);
      debugPrint("got serial port: $port");
    } catch (e) {
      debugPrint(e.toString());
      return;
    }

    if (port?.readable == null) {
      // Open the serial port.
      await port
          ?.open(
            JSSerialOptions(
              baudRate: 115200,
              dataBits: 8,
              stopBits: 1,
              parity: "none",
              bufferSize: 64,
              flowControl: "none",
            ),
          )
          .toDart;

      debugPrint("port opened: ${port?.readable}");
      if (port?.getInfo().usbVendorId == PICOTRACKERADVANCE_VENDOR_ID &&
          port?.getInfo().usbProductId == PICOTRACKERADVANCE_PRODUCT_ID) {
        _isAdvance = true;
      }
    } else {
      debugPrint("port already opened: ${port?.readable}");
    }
    // Listen to data coming from the serial device.
    final reader = port?.readable?.getReader() as ReadableStreamDefaultReader;

    if (port != null) {
      debugPrint("port opened: ${port?.readable}");
      // request full screen refresh after opening
      final request = Uint8List.fromList([REMOTE_COMMAND_MARKER, 0x02]);
      final JSUint8Array jsReq = request.toJS;
      final writer = port?.writable?.getWriter();
      writer?.write(jsReq);
      // Allow the serial port to be closed later.
      writer?.releaseLock();
    }

    while (true) {
      final result = await reader.read().toDart;
      if (result.done) {
        // Allow the serial port to be closed later.
        reader.releaseLock();
        break;
      } else {
        // value is a Uint8Array.
        onSerialData(result.value as JSUint8Array);
      }
    }
  }

  void onSerialData(JSUint8Array data) {
    // print("$data");
    final byteBuf = data.toDart;
    for (int i = 0; i < byteBuf.lengthInBytes; i++) {
      cmdBuilder.addByte(byteBuf[i]);
    }
  }
}
