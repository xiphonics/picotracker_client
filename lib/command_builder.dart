// ignore_for_file: constant_identifier_names, avoid_print

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'commands.dart';

const REMOTE_COMMAND_MARKER = 0xFE;
const REMOTE_COMMAND_TEXT = 0x02;
const REMOTE_COMMAND_CLEAR = 0x03;
const REMOTE_COMMAND_SET_COLOUR = 0x04;
const REMOTE_COMMAND_SET_FONT = 0x05;
const REMOTE_COMMAND_DRAWRECT = 0x06;

const ASCII_SPACE_OFFSET = 0xF;
const INVERT_ON = 0x7F;

// Byte escaping constants
const REMOTE_UI_ESC_CHAR = 0xFD;
const REMOTE_UI_ESC_XOR = 0x20;

enum CommandType {
  TEXT(4),
  CLEAR(3),
  SET_COLOUR(3),
  SET_FONT(1),
  DRAW_RECT(8);

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
      case REMOTE_COMMAND_DRAWRECT:
        return CommandType.DRAW_RECT;
      default:
        return null;
    }
  }
}

class CmdBuilder {
  CommandType? _type;
  final List<int> _byteBuffer = [];
  bool cmdStarted = false;
  bool escapeNext =
      false; // Flag to indicate if the next byte should be unescaped
  final _commandStreamController = StreamController<Command>.broadcast();

  Stream<Command> get commands => _commandStreamController.stream;

  void addByte(int byte) {
    // debugPrint("addByte raw: $byte");
    // Handle byte escaping
    if (escapeNext) {
      // Unescape the byte by XORing with REMOTE_UI_ESC_XOR
      byte = byte ^ REMOTE_UI_ESC_XOR;
      escapeNext = false;
    } else {
      // Check for escape character
      if (byte == REMOTE_UI_ESC_CHAR) {
        escapeNext = true;
        return;
      }

      // Normal command processing
      if (byte == REMOTE_COMMAND_MARKER) {
        _reset();
        cmdStarted = true;
        return;
      } else if (_type == null && cmdStarted) {
        _type = CommandType.fromMarkerByte(byte);
        return;
      }
    }

    if (cmdStarted) {
      _byteBuffer.add(byte);
      if (_byteBuffer.length == _type?.paramCount) {
        _build();
      }
    }
  }

  // build command if we have all the bytes for it
  void _build() {
    switch (_type) {
      case CommandType.TEXT:
        final cmd = DrawCmd(
          char: _byteBuffer[0],
          // x & y co-ords are 1 indexed to avoid sending null chars in the serial data
          x: _byteBuffer[1] - ASCII_SPACE_OFFSET,
          y: _byteBuffer[2] - ASCII_SPACE_OFFSET,
          invert: _byteBuffer[3] == INVERT_ON,
        );
        _reset();
        if (cmd.x > 31 || cmd.y > 23) {
          debugPrint("BAD DRAW DATA:${cmd.x} ${cmd.y} [${cmd.char}]");
        } else {
          _commandStreamController.add(cmd);
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
          debugPrint("BAD CLEAR DATA:$_byteBuffer");
        }
        break;
      case CommandType.SET_COLOUR:
        // debugPrint("SET_COLOUR command received with bytes: $_byteBuffer");
        if (_byteBuffer.length == _type!.paramCount) {
          final r = _byteBuffer[0];
          final g = _byteBuffer[1];
          final b = _byteBuffer[2];

          final cmd = ColourCmd(r: r, g: g, b: b);
          _commandStreamController.add(cmd);
          _reset();
        }
        break;
      case CommandType.SET_FONT:
        if (_byteBuffer.length == _type!.paramCount) {
          final index = _byteBuffer[0] - ASCII_SPACE_OFFSET;
          final cmd = FontCmd(index: index);
          _commandStreamController.add(cmd);
        }
        _reset();
        break;
      case CommandType.DRAW_RECT:
        if (_byteBuffer.length == _type!.paramCount) {
          final cmd = DrawRectCmd(
            x: (_byteBuffer[0] | (_byteBuffer[1] << 8)) & 0xFFFF,
            y: (_byteBuffer[2] | (_byteBuffer[3] << 8)) & 0xFFFF,
            width: (_byteBuffer[4] | (_byteBuffer[5] << 8)) & 0xFFFF,
            height: (_byteBuffer[6] | (_byteBuffer[7] << 8)) & 0xFFFF,
          );
          _commandStreamController.add(cmd);
        }
        _reset();
        break;
      case null:
        break;
    }
  }

  void _reset() {
    _byteBuffer.clear();
    _type = null;
    cmdStarted = false;
    escapeNext = false; // Reset the escape flag
  }
}
