// ignore_for_file: constant_identifier_names

import 'dart:ui';

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
  final int x;
  final int y;
  final int width;
  final int height;

  DrawRectCmd({
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

  String get char => String.fromCharCode(_char);

  GridCell(this._char, this.color, this.invert);

  @override
  String toString() {
    return "[$char] [$color]";
  }
}
