// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/pico_app.dart';
import 'package:picotracker_client/picotracker/screen_char_grid.dart';
import '../commands.dart';
import '../main_screen.dart';

const buildVersion = String.fromEnvironment('BUILD_NUMBER');

class PicoScreenPainter extends CustomPainter {
  final ScreenCharGrid grid;
  final List<DrawRectCmd> rects;
  final bool isAdvance;

  PicoScreenPainter({
    required this.grid,
    required this.rects,
    required this.isAdvance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw main background
    final bgPaint = Paint()..color = grid.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Draw rectangles (waveform)
    final rectPaint = Paint();
    final double scaleX = size.width / 320.0;
    final double scaleY = size.height / 240.0;

    for (final rectCmd in rects) {
      rectPaint.color = grid.colorPalette[rectCmd.colorIdx];
      final rect = Rect.fromLTWH(
        rectCmd.x.toDouble() * scaleX,
        rectCmd.y.toDouble() * scaleY,
        (rectCmd.width.toDouble() * scaleX) + 1,
        (rectCmd.height.toDouble() * scaleY) + 1,
      );
      canvas.drawRect(rect, rectPaint);
    }

    // 3. Draw character grid
    final double charWidth = (size.width / COLS).roundToDouble();
    final double charHeight = (size.height / ROWS).roundToDouble();
    final double fontSize = isAdvance ? 22.0 : 16.0;
    final textStyle = TextStyle(
      fontFamily: fontNotifier.value.name,
      fontSize: fontSize,
      height: 1.0,
    );

    final cellBgPaint = Paint();

    for (int y = 0; y < ROWS; y++) {
      for (int x = 0; x < COLS; x++) {
        final cell = grid.getRows()[y][x];
        final cellRect =
            Rect.fromLTWH(x * charWidth, y * charHeight, charWidth, charHeight);

        final isInvertedSpaceChar = cell.char == " " && cell.invert;
        final cellBackgroundColor = isInvertedSpaceChar
            ? cell.color
            : (cell.invert ? cell.color : Colors.transparent);

        if (cellBackgroundColor != Colors.transparent) {
          cellBgPaint.color = cellBackgroundColor;
          canvas.drawRect(cellRect, cellBgPaint);
        }

        final textColor = isInvertedSpaceChar
            ? cell.color
            : (cell.invert ? grid.background : cell.color);

        final character = isInvertedSpaceChar ? "\u2588" : cell.char;

        final textSpan = TextSpan(
          text: character,
          style: textStyle.copyWith(color: textColor),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(minWidth: 0, maxWidth: charWidth);

        final textX = cellRect.left + (charWidth - textPainter.width) / 2;
        final textY = cellRect.top + (charHeight - textPainter.height) / 2;

        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(PicoScreenPainter oldDelegate) {
    return true; // Inefficient, but guarantees repaint for now
  }
}

class PicoScreen extends StatelessWidget {
  final ScreenCharGrid grid;
  final Color backgroundColor;
  final bool connected;
  final List<DrawRectCmd> rects;

  const PicoScreen(this.grid, this.backgroundColor, this.rects,
      {super.key, required this.connected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: !connected,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("picoTracker Client  [build $buildVersion]",
                style: Theme.of(context).textTheme.headlineSmall),
          ),
        ),
        SizedBox(
          height: 754,
          width: 904,
          child: Padding(
            padding: const EdgeInsets.only(
                top: 100, bottom: 98, left: 60, right: 75),
            child: Container(
              child: CustomPaint(
                size: const Size(640, 480),
                painter: PicoScreenPainter(
                  grid: grid,
                  rects: rects,
                  isAdvance: serialHandler.isAdvance(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}