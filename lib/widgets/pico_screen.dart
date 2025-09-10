// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/picotracker/screen_char_grid.dart';
import 'package:picotracker_client/widgets/screen_char_row.dart';

import '../commands.dart';

final KEY_LEFT = int.parse("1", radix: 2);
final KEY_DOWN = int.parse("10", radix: 2);
final KEY_RIGHT = int.parse("100", radix: 2);
final KEY_UP = int.parse("1000", radix: 2);
final KEY_L = int.parse("10000", radix: 2);

const buildVersion = String.fromEnvironment('BUILD_NUMBER');

class RectanglePainter extends CustomPainter {
  final List<DrawRectCmd> rects;
  final ScreenCharGrid grid;
  final bool isAdvance;

  RectanglePainter(this.rects, this.grid, this.isAdvance);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX;
    final double scaleY;

    if (isAdvance) {
      scaleX = 1.0;
      scaleY = 1.0;
    } else {
      scaleX = size.width / 320.0;
      scaleY = size.height / 240.0;
    }

    final paint = Paint();
    for (final rectCmd in rects) {
      paint.color = grid.colorPalette[rectCmd.colorIdx];
      final rect = Rect.fromLTWH(
        rectCmd.x.toDouble() * scaleX,
        rectCmd.y.toDouble() * scaleY,
        rectCmd.width.toDouble() * scaleX,
        rectCmd.height.toDouble() * scaleY,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(RectanglePainter oldDelegate) {
    return oldDelegate.rects != rects;
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
              width: 320 * 2,
              height: 240 * 2,
              color: backgroundColor,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: grid
                        .getRows()
                        .map((row) => ScreenCharRow(
                              row,
                              grid,
                            ))
                        .toList(),
                  ),
                  SizedBox(
                    width: 320 * 2,
                    height: 240 * 2,
                    child: CustomPaint(
                      painter: RectanglePainter(rects, grid, grid.isAdvance),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
