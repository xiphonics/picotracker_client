// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/commands.dart';

const COLS = 32;
const ROWS = 24;

typedef Coord = ({int x, int y});

class ScreenCharGrid {
  Color _currentColour = Colors.white;
  Color _backgroundColor = Colors.black;
  List<GridCell> _gridlist =
      List.filled(COLS * ROWS, GridCell(0, Colors.black, false));

  final List<Color> colorPalette = [
    const Color(0xFF000000),
    const Color(0xFF0049E5),
    const Color(0xFF00B926),
    const Color(0xFF00E371),
    const Color(0xFF009CF3),
    const Color(0xFF00A324),
    const Color(0xFF00EC46),
    const Color(0xFF00F70D),
    const Color(0xFF00ffff),
    const Color(0xFF001926),
    const Color(0xFF002A49),
    const Color(0xFF004443),
    const Color(0xFF00A664),
    const Color(0xFF0002B0),
    const Color(0xFF00351E),
    const Color(0xFF00B6FD)
  ];

  Color get color => _currentColour;

  Color get background => _backgroundColor;

  void setChar(Coord pos, int char, bool invert) {
    final int offset = (pos.y * COLS) + pos.x;
    final nuCell = GridCell(char, _currentColour, invert);
    _gridlist[offset] = nuCell;
  }

  void clear() {
    _gridlist = List.filled(COLS * ROWS, GridCell(0, _backgroundColor, false));
  }

  void setColor(int r, int g, int b) {
    _currentColour = Color.fromRGBO(r, g, b, 1);
  }

  void setBackground(int r, int g, int b) {
    _backgroundColor = Color.fromRGBO(r, g, b, 1);
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
