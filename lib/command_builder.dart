// ignore_for_file: constant_identifier_names, avoid_print

import 'dart:async';
import 'package:picotracker_client/pico_app.dart';

import 'commands.dart';

const REMOTE_COMMAND_MARKER = 0xFE;
const REMOTE_COMMAND_TEXT = 0x02;
const REMOTE_COMMAND_CLEAR = 0x03;
const REMOTE_COMMAND_SET_COLOUR = 0x04;
const REMOTE_COMMAND_SET_FONT = 0x05;

enum CommandType {
  TEXT(4),
  CLEAR(3),
  SET_COLOUR(3),
  SET_FONT(3);

  const CommandType(this.paramCount);
  final int paramCount;

  static CommandType? fromMarkerByte(int byte) {
    switch (byte) {
      case REMOTE_COMMAND_TEXT:
        return CommandType.TEXT;
      case REMOTE_COMMAND_CLEAR:
        return CommandType.CLEAR;
      case REMOTE_COMMAND_SET_COLOUR:
        return CommandType.SET_COLOUR;
      case REMOTE_COMMAND_SET_FONT:
        return CommandType.SET_FONT;
      default:
        return null;
    }
  }
}

class CmdBuilder {
  CommandType? _type;
  final List<int> _byteBuffer = [];
  bool cmdStarted = false;
  final _commandStreamController = StreamController<Command>.broadcast();

  Stream<Command> get commands => _commandStreamController.stream;

  void addByte(int byte) {
    if (byte == REMOTE_COMMAND_MARKER) {
      if (cmdStarted) {
        print("INCOMPLETE CMD:[$_type] $_byteBuffer");
      }
      _reset();
      cmdStarted = true;
    } else if (_type == null && cmdStarted) {
      _type = CommandType.fromMarkerByte(byte);
    } else {
      if (cmdStarted) {
        _byteBuffer.add(byte);
      }
    }
    _build();
  }

  // build command if we have all the bytes for it
  void _build() {
    switch (_type) {
      case CommandType.TEXT:
        if (_byteBuffer.length == _type!.paramCount) {
          final cmd = DrawCmd(
            char: _byteBuffer[0],
            // x & y co-ords are 1 indexed to avoid sending null chars in the serial data
            x: _byteBuffer[1] - ASCII_SPACE_OFFSET,
            y: _byteBuffer[2] - ASCII_SPACE_OFFSET,
            invert: _byteBuffer[3] == INVERT_ON,
          );
          _reset();
          if (cmd.x > 31 || cmd.y > 23) {
            print("BAD DRAW DATA:${cmd.x} ${cmd.y} [${cmd.char}]");
          } else {
            _commandStreamController.add(cmd);
          }
        }
        break;
      case CommandType.CLEAR:
        if (_byteBuffer.length == _type!.paramCount) {
          final cmd = ClearCmd(
            r: _byteBuffer[0],
            g: _byteBuffer[1],
            b: _byteBuffer[2],
          );
          _commandStreamController.add(cmd);
          _reset();
        } else {
          print("BAD CLEAR DATA:$_byteBuffer");
        }
        break;
      case CommandType.SET_COLOUR:
        if (_byteBuffer.length == _type!.paramCount) {
          final cmd = ColourCmd(
            r: _byteBuffer[0],
            g: _byteBuffer[1],
            b: _byteBuffer[2],
          );
          _commandStreamController.add(cmd);
          _reset();
        }
        break;
      case CommandType.SET_FONT:
        if (_byteBuffer.length != 1) {
          print("BAD FONT DATA:$_byteBuffer");
          break;
        }
        final index = _byteBuffer[0] - ASCII_SPACE_OFFSET;
        if (index < PtFont.values.length) {
          final cmd = FontCmd(index: index);
          _commandStreamController.add(cmd);
          _reset();
        } else {
          print("BAD FONT INDEX:$index");
        }
        break;
      case null:
        break;
    }
  }

  void _reset() {
    _byteBuffer.clear();
    _type = null;
    cmdStarted = false;
  }
}
