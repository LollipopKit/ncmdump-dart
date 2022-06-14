import 'dart:io';

import 'package:ncmdump/ncmdump.dart';

Future<void> main() async {
  final ncm = NCM();
  final raw = await File('a.ncm').readAsBytes();
  ncm.parse(raw);

  /// call parse() before you use any of other methods.
  final target = await File('a.${ncm.meta.format}');
  await target.writeAsBytes(ncm.music);
}
