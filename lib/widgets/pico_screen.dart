// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/pico_app.dart';
import '../commands.dart';
import '../main_screen.dart';

const buildVersion = String.fromEnvironment('BUILD_NUMBER');

class PicoScreenPainter extends CustomPainter {
  final List<Command> commands;
  final bool isAdvance;

  PicoScreenPainter({
    required this.commands,
    required this.isAdvance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Color currentColor = Colors.white;
    Color backgroundColor = Colors.black;

    // Process commands to set initial state
    for (final command in commands) {
      if (command is ClearCmd) {
        backgroundColor = Color.fromRGBO(command.r, command.g, command.b, 1);
      }
    }

    // 1. Draw main background
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Sequentially process all commands to draw the screen
    final rectPaint = Paint();
    final cellBgPaint = Paint();
    final deviceScreenWidth = isAdvance ? 720.0 : 320.0;
    final deviceScreenHeight = isAdvance ? 720.0 : 240.0;
    final double scaleX = size.width / deviceScreenWidth;
    final double scaleY = size.height / deviceScreenHeight;
    final double charWidth = (size.width / 32).roundToDouble();
    final double charHeight = (size.height / 24).roundToDouble();

    for (final command in commands) {
      switch (command) {
        case ColourCmd():
          currentColor = Color.fromRGBO(command.r, command.g, command.b, 1);
          break;

        case DrawRectCmd():
          // debugPrint("Drawing rect with color: $currentColor");
          rectPaint.color = currentColor;
          final rect = Rect.fromLTWH(
            command.x.toDouble() * scaleX,
            command.y.toDouble() * scaleY,
            (command.width.toDouble() * scaleX) + 1,
            (command.height.toDouble() * scaleY) + 1,
          );
          canvas.drawRect(rect, rectPaint);
          break;

        case DrawCmd():
          // Determine cell's background and foreground colors
          final bool isInverted = command.invert;
          final Color cellBgColor = isInverted ? currentColor : backgroundColor;
          final Color charColor = isInverted ? backgroundColor : currentColor;

          final cellRect = Rect.fromLTWH(command.x * charWidth,
              command.y * charHeight, charWidth, charHeight);

          // Always draw the cell's background first to clear old state
          cellBgPaint.color = cellBgColor;
          canvas.drawRect(cellRect, cellBgPaint);

          // Then draw the character
          final textStyle = TextStyle(
            fontFamily: fontNotifier.value.name.replaceAll("_", " "),
            fontSize: isAdvance ? 22.0 : 16.0,
            height: 1.0,
            color: charColor,
          );

          final textSpan = TextSpan(
            text: String.fromCharCode(command.char),
            style: textStyle,
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(minWidth: 0, maxWidth: charWidth);

          final textX = cellRect.left + (charWidth - textPainter.width) / 2;
          final textY = cellRect.top + (charHeight - textPainter.height) / 2;

          textPainter.paint(canvas, Offset(textX, textY));
          break;

        default:
          break;
      }
    }
  }

  @override
  bool shouldRepaint(PicoScreenPainter oldDelegate) {
    return true; // Inefficient, but guarantees repaint for now
  }
}

class PicoScreen extends StatelessWidget {
  final List<Command> commands;
  final bool connected;

  const PicoScreen(this.commands, {super.key, required this.connected});

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
            child: CustomPaint(
              size: const Size(640, 480),
              painter: PicoScreenPainter(
                commands: commands,
                isAdvance: serialHandler.isAdvance(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
