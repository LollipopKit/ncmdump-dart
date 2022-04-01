import 'dart:typed_data';

extension Uint8ListX on Uint8List {
  /// convert to hex string
  String get hex {
    var s = '';
    for (final element in this) {
      s += element.toRadixString(16);
    }
    return s;
  }

  /// convert to string
  String get string => String.fromCharCodes(this);

  /// convert 4 bytes to int (length)
  int getLength() {
    int len = 0;
    len |= this[0] & 0xff;
    len |= (this[1] & 0xff) << 8;
    len |= (this[2] & 0xff) << 16;
    len |= (this[3] & 0xff) << 24;
    return len;
  }
}

extension ByteDataX on ByteData {
  /// bytedata to string
  String get string {
    return buffer.asUint8List().string;
  }
}

/// hex string to string
String hexParse(String hex) {
  final len = hex.length ~/ 2;
  var s = '';
  for (var i = 0; i < len * 2; i += 2) {
    s += String.fromCharCode(int.tryParse(hex.substring(i, i + 2), radix: 16)!);
  }
  return s;
}
