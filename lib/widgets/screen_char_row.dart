// ignore_for_file: constant_identifier_names, non_constant_identifier_names

// Removed unused import

import 'package:flutter/material.dart';
import 'package:picotracker_client/picotracker/screen_char_grid.dart';
import '../commands.dart';

class CharacterPainter extends CustomPainter {
  final String character;
  final Color color;
  final Color backgroundColor;
  final double fontSize;
  final String fontFamily;

  CharacterPainter({
    required this.character,
    required this.color,
    required this.backgroundColor,
    required this.fontFamily,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background with a slightly larger rectangle to prevent edge artifacts
    final bgPaint = Paint()
      ..color = backgroundColor
      ..isAntiAlias = false; // Disable anti-aliasing for background

    // Draw background with 0.5 pixel inset to ensure full coverage
    canvas.drawRect(
      Rect.fromLTWH(-0.5, -0.5, size.width + 1, size.height + 1),
      bgPaint,
    );

    // Create a simple text style with required letter spacing
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
      height: 1.0,
      letterSpacing: 2.5, // more spacing to better match the ST7789 display
    );

    // Create and layout the text painter
    final textPainter = TextPainter(
      text: TextSpan(text: character, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Calculate the center offset
    final centerX = (size.width - textPainter.width) / 2;
    final centerY = (size.height - textPainter.height) / 2;

    // Draw the text centered in the cell
    textPainter.paint(
      canvas,
      Offset(centerX, centerY),
    );
  }

  @override
  bool shouldRepaint(CharacterPainter oldDelegate) {
    return oldDelegate.character != character ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class ScreenCharRow extends StatelessWidget {
  // Increased width for more horizontal spacing
  static const double charWidth = 16.0;
  static const double charHeight = 22.0;
  static const double fontSize = 22.0;

  final List<GridCell> rowChars;
  final ScreenCharGrid grid;

  const ScreenCharRow(this.rowChars, this.grid, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontFamily = theme.textTheme.titleLarge?.fontFamily ?? 'monospace';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: rowChars.map((cell) {
        final isInvertedSpaceChar = cell.char == " " && cell.invert;

        // For inverted space characters, use the cell's color as background
        // For regular characters, use the grid's background unless inverted
        final backgroundColor = isInvertedSpaceChar
            ? cell.color
            : (cell.invert ? cell.color : grid.background);

        // Text color is the inverse of the background when inverted
        final textColor = isInvertedSpaceChar
            ? cell.color
            : (cell.invert ? grid.background : cell.color);

        return CustomPaint(
          size: const Size(charWidth, charHeight),
          painter: CharacterPainter(
            character: isInvertedSpaceChar ? "\u2588" : cell.char,
            color: textColor,
            backgroundColor: backgroundColor,
            fontFamily: fontFamily,
            fontSize: fontSize,
          ),
        );
      }).toList(),
    );
  }
}
