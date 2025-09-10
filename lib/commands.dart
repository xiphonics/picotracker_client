// ignore_for_file: constant_identifier_names

import 'dart:ui';

const REMOTE_COMMAND_MARKER = 0x01;
const ASCII_SPACE_OFFSET = 0xF;
const INVERT_ON = 0x7F;

sealed class Command {}

class DrawCmd implements Command {
  final int char;
  final int x;
  final int y;
  final bool invert;

  DrawCmd({
    required this.char,
    required this.x,
    required this.y,
    required this.invert,
  });
}

class ClearCmd implements Command {
  final int r; // Red component
  final int g; // Green component
  final int b; // Blue component
  const ClearCmd({
    required this.r,
    required this.g,
    required this.b,
  });
}

class ColourCmd implements Command {
  final int r; // Red component
  final int g; // Green component
  final int b; // Blue component

  ColourCmd({
    required this.r,
    required this.g,
    required this.b,
  });
}

class FontCmd implements Command {
  final int index;
  FontCmd({
    required this.index,
  });
}

class DrawRectCmd implements Command {
  final int colorIdx;
  final int x;
  final int y;
  final int width;
  final int height;

  DrawRectCmd({
    required this.colorIdx,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

class GridCell {
  final int _char;
  final Color color;
  final bool invert;

  // SPACE char instead of ascii 0
  String get char =>
      String.fromCharCode(_char != 0 ? _char : ASCII_SPACE_OFFSET);

  GridCell(this._char, this.color, this.invert);

  @override
  String toString() {
    return "[$char] [$color]";
  }
}
