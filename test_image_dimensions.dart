import 'dart:io';
import 'dart:typed_data';

void main() {
  final files = ['assets/logo.png', 'assets/splash.png'];
  for (final filename in files) {
    try {
      final bytes = File(filename).readAsBytesSync();
      // PNG header starts with 89 50 4E 47 0D 0A 1A 0A
      // Then IHDR chunk: 4 bytes length, 4 bytes "IHDR", then 4 bytes width, 4 bytes height
      final bd = ByteData.sublistView(bytes);
      final width = bd.getInt32(16, Endian.big);
      final height = bd.getInt32(20, Endian.big);
      print('$filename -> Width: $width, Height: $height');
    } catch (e) {
      print('$filename -> Error: $e');
    }
  }
}
