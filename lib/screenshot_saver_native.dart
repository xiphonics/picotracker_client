import 'dart:io';
import 'dart:typed_data';

Future<void> savePNG(Uint8List bytes, {required String fileName}) async {
  final file = File('${Directory.current.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
}
