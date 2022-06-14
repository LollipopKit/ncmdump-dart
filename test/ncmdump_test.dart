import 'dart:io';

import 'package:ncmdump/ncmdump.dart';
import 'package:test/test.dart';

const ncmPath = 'test/assets/a.ncm';
const mp3Path = 'test/assets/a.mp3';

void main() {
  test('convert .ncm', () async {
    final ncmFile = File(ncmPath);
    final mp3File = File(mp3Path);
    if (!ncmFile.existsSync() || !mp3File.existsSync()) {
      print(
          'please put your own test .ncm file in "$ncmPath", and run "python3 ncmdump.py \'test/assets\'"');
      return;
    }
    final raw = await ncmFile.readAsBytes();
    final target = await mp3File.readAsBytes();
    final ncm = NCM();
    ncm.parse(raw);
    // ignore: avoid_print
    print(
        'name: ${ncm.meta.musicName}, format: ${ncm.meta.format}, artist: ${ncm.meta.artist}');
    expect(ncm.music, target);
  });
}
