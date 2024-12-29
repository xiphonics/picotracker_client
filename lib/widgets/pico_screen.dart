// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:picotracker_client/picotracker/screen_char_grid.dart';
import 'package:picotracker_client/widgets/screen_char_row.dart';

final KEY_LEFT = int.parse("1", radix: 2);
final KEY_DOWN = int.parse("10", radix: 2);
final KEY_RIGHT = int.parse("100", radix: 2);
final KEY_UP = int.parse("1000", radix: 2);
final KEY_L = int.parse("10000", radix: 2);

const buildVersion = String.fromEnvironment('BUILD_NUMBER');

class PicoScreen extends StatelessWidget {
  final ScreenCharGrid grid;
  final Color backgroundColor;
  final bool connected;

  const PicoScreen(this.grid, this.backgroundColor,
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
              height: 320 * 2,
              width: 240 * 2,
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: grid
                    .getRows()
                    .map((row) => ScreenCharRow(
                          row,
                          grid,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
