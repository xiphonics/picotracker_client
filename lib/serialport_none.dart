import 'command_builder.dart';

class SerialPortHandler {
  SerialPortHandler(CmdBuilder cmdBuilder);

  Function(bool)? onAdvanceModeChanged;

  void chooseSerialDevice() async {}

  bool isConnected() => false;

  bool isAdvance() => false;
}
