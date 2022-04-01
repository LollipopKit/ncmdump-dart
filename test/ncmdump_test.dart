import 'dart:io';


import 'package:ncmdump/ncmdump.dart';
import 'package:test/test.dart';

void main() {
  test('convert .ncm', () async {
    final raw = await File('test/assets/a.ncm').readAsBytes();
    final target = await File('test/assets/a.mp3').readAsBytes();
    final ncm = NCM();
    ncm.setRaw(raw);
    ncm.parse();
    // ignore: avoid_print
    print(
      'name: ${ncm.meta.musicName}, format: ${ncm.meta.format}, artist: ${ncm.meta.artist}');
    expect(ncm.music, target);
  });
}
