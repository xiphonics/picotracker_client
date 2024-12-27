// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/picotracker/screen_char_grid.dart';

import '../commands.dart';

class ScreenCharRow extends StatelessWidget {
  final List<GridCell> rowChars;
  final ScreenCharGrid grid;

  const ScreenCharRow(this.rowChars, this.grid, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: rowChars.map((cell) {
        bool isInvertedSpaceChar = cell.char == " " && cell.invert;
        return Text(
          // need this ugly hack due to open Flutter bug:
          // https://github.com/flutter/flutter/issues/112766
          isInvertedSpaceChar ? "\u2588" : cell.char,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                height: 1.2,
                letterSpacing: 1,
                fontSize: 19,
                color: isInvertedSpaceChar
                    ? cell.color
                    : (cell.invert ? grid.background : cell.color),
                backgroundColor: isInvertedSpaceChar
                    ? cell.color
                    : (cell.invert ? cell.color : grid.background),
                decoration: TextDecoration.none,
              ),
        );
      }).toList(),
    );
  }
}
