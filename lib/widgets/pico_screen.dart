// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../commands.dart';
import '../screen_constants.dart';

const buildVersion = String.fromEnvironment('BUILD_NUMBER');

class PicoScreenPainter extends CustomPainter {
  final List<Command> commands;
  final bool isAdvance;
  final int currentFont;
  static ui.Image? _fontImage;

  PicoScreenPainter({
    required this.commands,
    required this.isAdvance,
    required this.currentFont,
  }) {
    if (isAdvance) {
      _loadFontAsync('assets/fonts/font_adv.png');
    } else if (!isAdvance) {
      // Load fonts based on currentFont index
      if (currentFont == 0) {
        _loadFontAsync('assets/fonts/font_hourglass.png');
      } else if (currentFont == 1) {
        _loadFontAsync('assets/fonts/font_yousquared.png');
      } else if (currentFont == 2) {
        _loadFontAsync('assets/fonts/font_wide.png');
      }
    }
  }

  static void _loadFontAsync(String path) async {
    final ByteData data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    _fontImage = frame.image;
  }

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
    final rectPaint = Paint()..isAntiAlias = false;
    final cellBgPaint = Paint()..isAntiAlias = false;
    final deviceScreenWidth =
        (isAdvance ? kAdvanceScreenWidth : kScreenWidth).toDouble();
    final deviceScreenHeight =
        (isAdvance ? kAdvanceScreenHeight : kScreenHeight).toDouble();
    final double scaleX = size.width / deviceScreenWidth;
    final double scaleY = size.height / deviceScreenHeight;

    final double charWidth;
    final double charHeight;
    final double offsetX;
    final double offsetY;

    if (isAdvance) {
      charWidth = 22.0;
      charHeight = 30.0;
      offsetX = (size.width - (32 * charWidth)) / 2.0;
      offsetY = (size.height - (24 * charHeight)) / 2.0;
    } else {
      charWidth = size.width / 32.0;
      charHeight = size.height / 24.0;
      offsetX = 0;
      offsetY = 0;
    }

    for (final command in commands) {
      switch (command) {
        case ColourCmd():
          currentColor = Color.fromRGBO(command.r, command.g, command.b, 1);
          break;

        case FontCmd():
          break;

        case DrawRectCmd():
          // debugPrint("Drawing rect with color: $currentColor");
          rectPaint.color = currentColor;
          final rect = Rect.fromLTWH(
            command.x.toDouble() * scaleX,
            command.y.toDouble() * scaleY,
            (command.width.toDouble() * scaleX),
            (command.height.toDouble() * scaleY),
          );
          canvas.drawRect(rect, rectPaint);
          break;

        case DrawCmd():
          if (_fontImage == null) {
            // Font image not loaded yet; skip drawing
            break;
          }

          // Determine cell's background and foreground colors
          final bool isInverted = command.invert;
          final Color cellBgColor = isInverted ? currentColor : backgroundColor;
          final Color charColor = isInverted ? backgroundColor : currentColor;

          final cellRect = Rect.fromLTWH(offsetX + command.x * charWidth,
              offsetY + command.y * charHeight, charWidth, charHeight);

          // Always draw the cell's background first to clear old state
          cellBgPaint.color = cellBgColor;
          canvas.drawRect(cellRect, cellBgPaint);

          // Use PNG font for Advance mode (16x16 character grid, antialiased)
          final charRow = command.char ~/ 16;
          final charCol = command.char % 16;

          // Source dimensions in the image (equal divisions)
          final fontCharWidth = _fontImage!.width / 16;
          final fontCharHeight = _fontImage!.height / 16;

          final srcRect = Rect.fromLTWH(
            charCol * fontCharWidth,
            charRow * fontCharHeight,
            fontCharWidth,
            fontCharHeight,
          );

          // Draw with or without antialiasing based on mode
          final paint = Paint()
            ..isAntiAlias = isAdvance
            ..filterQuality =
                isAdvance ? FilterQuality.high : FilterQuality.none
            ..colorFilter = ColorFilter.mode(charColor, BlendMode.srcIn);

          canvas.drawImageRect(
            _fontImage!,
            srcRect,
            cellRect,
            paint,
          );
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

class PicoScreen extends StatefulWidget {
  final List<Command> commands;
  final bool connected;
  final bool isAdvanceMode;
  final int currentFont;
  final GlobalKey repaintBoundaryKey;

  const PicoScreen(this.commands,
      {super.key,
      required this.connected,
      required this.isAdvanceMode,
      required this.currentFont,
      required this.repaintBoundaryKey});

  @override
  State<PicoScreen> createState() => _PicoScreenState();
}

class _PicoScreenState extends State<PicoScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !widget.connected,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("picoTracker Client  [build $buildVersion]",
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),
          SizedBox(
            width:
                (widget.isAdvanceMode ? kAdvanceScreenWidth : kScreenWidth * 2)
                    .toDouble(),
            height: (widget.isAdvanceMode
                    ? kAdvanceScreenHeight
                    : kScreenHeight * 2)
                .toDouble(),
            child: RepaintBoundary(
              key: widget.repaintBoundaryKey,
              child: CustomPaint(
                painter: PicoScreenPainter(
                  commands: widget.commands,
                  isAdvance: widget.isAdvanceMode,
                  currentFont: widget.currentFont,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
