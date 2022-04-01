import 'dart:io';

import 'package:args/args.dart';
import 'package:ncmdump/ncmdump.dart';

const NCM_SUFFIX = '.ncm';
const AUDIO_SUFFIX = ['.mp3', '.flac'];
const TIME_SUFFIX_MAP = {
  'ms': 1,
  's': 1000,
  'min': 60000,
  'h': 3600000,
};

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addFlag('override',
      defaultsTo: false, abbr: 'o', help: 'override converted files');
  parser.addFlag('recursive',
      defaultsTo: false,
      abbr: 'r',
      help: 'convert all files in sub-directories and this directory');
  final result = parser.parse(args);
  final path = result.rest.first;
  final override = result['override'];
  final recursive = result['recursive'];

  final filePaths = <String>[];

  if (await FileSystemEntity.isDirectory(path)) {
    final dir = Directory(path);
    for (final entity in dir.listSync(recursive: recursive)) {
      if (entity is File && entity.path.endsWith(NCM_SUFFIX)) {
        filePaths.add(entity.path);
      }
    }
  } else {
    filePaths.add(path);
  }

  final taskNum = filePaths.length;
  final stopWatch = Stopwatch()..start();

  final ncm = NCM();

  var idx = 1;
  for (final filePath in filePaths) {
    final file = File(filePath);
    var exist = false;
    for (final suffix in AUDIO_SUFFIX) {
      final audioPath = filePath.replaceAll(NCM_SUFFIX, suffix);
      if (await File(audioPath).exists()) {
        exist = true;
        break;
      }
    }

    if (!override && exist) {
      print('[SKIP] $filePath');
      idx++;
      continue;
    }

    ncm.setRaw(await file.readAsBytes());
    ncm.parse();
    final targetName = filePath.replaceAll(NCM_SUFFIX, '.${ncm.meta.format}');
    final targetFile = File(targetName);

    await targetFile.writeAsBytes(ncm.music);
    print('[$idx/$taskNum]  $targetName');
    idx++;
  }

  stopWatch.stop();
  final millSeconds = stopWatch.elapsedMilliseconds;
  var timeSuffix = '';
  var timeResult = 0.0;
  for (final suffix in TIME_SUFFIX_MAP.keys) {
    final time = millSeconds / TIME_SUFFIX_MAP[suffix]!;
    if (time > 1) {
      timeSuffix = suffix;
      timeResult = time;
    } else {
      break;
    }
  }
  print('\n[FINISH] Spent $timeResult $timeSuffix.');
}
