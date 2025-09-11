// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/commands.dart';

const COLS = 32;
const ROWS = 24;

typedef Coord = ({int x, int y});

class ScreenCharGrid {
  final bool isAdvance;
  Color _currentColour = Colors.white;
  Color _backgroundColor = Colors.black;
  List<GridCell> _gridlist =
      List.filled(COLS * ROWS, GridCell(0, Colors.black, false));
  List<DrawRectCmd> rects = [];

  ScreenCharGrid(this.isAdvance);

  Color get color => _currentColour;

  Color get background => _backgroundColor;

  void setChar(Coord pos, int char, bool invert) {
    final int offset = (pos.y * COLS) + pos.x;
    final nuCell = GridCell(char, _currentColour, invert);
    _gridlist[offset] = nuCell;
  }

  void clear() {
    _gridlist = List.filled(COLS * ROWS, GridCell(0, _backgroundColor, false));
    rects = [];
  }

  void setColor(int r, int g, int b) {
    // Convert from RGB888 to RGB565 and back to simulate the ST7789 display's color mapping
    // RGB565: 5 bits R, 6 bits G, 5 bits B
    final r565 = (r >> 3) & 0x1F; // 5 bits for red
    final g565 = (g >> 2) & 0x3F; // 6 bits for green
    final b565 = (b >> 3) & 0x1F; // 5 bits for blue

    // Convert back to RGB888
    final r888 = (r565 << 3) | (r565 >> 2); // Expand 5 bits to 8 bits
    final g888 = (g565 << 2) | (g565 >> 4); // Expand 6 bits to 8 bits
    final b888 = (b565 << 3) | (b565 >> 2); // Expand 5 bits to 8 bits

    final color = Color.fromRGBO(r888, g888, b888, 1);
    _currentColour = color;
  }

  void setBackground(int r, int g, int b) {
    _backgroundColor = Color.fromRGBO(r, g, b, 1);
  }

  void addRect(int x, int y, int width, int height) {
    rects = List.from(rects)
      ..add(DrawRectCmd(x: x, y: y, width: width, height: height));
  }

  List<List<GridCell>> getRows() {
    var currentRow = <GridCell>[];
    final rows = List<List<GridCell>>.empty(growable: true);
    // split into rows
    for (int i = 0; i < _gridlist.length; i++) {
      currentRow.add(_gridlist[i]);
      if ((i + 1) % COLS == 0) {
        rows.add(currentRow);
        // print("ROW[$currentRow]\n");
        currentRow = [];
      }
    }
    return rows;
  }
}
