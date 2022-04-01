// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:ncmdump/src/constant.dart';
import 'package:ncmdump/src/ext/convert.dart';
import 'package:ncmdump/src/model/meta.dart';

/// Example:
/// ```dart
/// final ncm = NCM();
/// final raw = await File('a.ncm').readAsBytes();
/// final target = await File('a.mp3').readAsBytes();
/// ncm.setRaw(raw);
/// ncm.parse();
/// // music data
/// print(ncm.music);
/// ```
class NCM {
  Uint8List? _raw;
  late String _magicHeader;
  late int _keyLength;
  late Uint8List key;
  late int _metaLength;
  late Meta meta;
  late int _imageSize;
  late Uint8List image;
  late Uint8List music;
  late Encrypter _coreCryptor;
  late Encrypter _metaCryptor;
  late IV _iv;

  NCM() {
    _iv = IV.fromLength(0);
    _coreCryptor = Encrypter(AES(Key.fromUtf8(coreKeyStr), mode: AESMode.ecb));
    _metaCryptor =
        Encrypter(AES(Key.fromUtf8(hexParse(metaKeyHex)), mode: AESMode.ecb));
  }

  /// Set raw data. [raw] must be a valid NCM file bytes.
  void setRaw(Uint8List raw) => _raw = raw;

  /// Parse raw data.
  /// If [_raw] is not set, please call [setRaw] first.
  void parse() {
    if (_raw == null) throw Exception('must call setRaw(Uint8List raw) first.');

    try {
      _magicHeader = _readMagicHeader();
      assert(_magicHeader == magicHeaderValue);
      _keyLength = _readKeyLength();
      key = _readKey();
      _metaLength = _readMetaLength();
      meta = _readMeta();
      _readCRC();
      _readGap();
      _imageSize = _readImageSize();
      image = _readImage();
      music = _readMusic();
    } catch (e) {
      print('parse failed: $e');
      rethrow;
    }
  }

  String _readMagicHeader() {
    final data = _raw!.sublist(0, 8);
    _raw = _raw!.sublist(10);
    return data.hex;
  }

  int _readKeyLength() {
    final data = _raw!.sublist(0, 4);
    _raw = _raw!.sublist(4);
    return data.getLength();
  }

  Uint8List _readKey() {
    final data = _raw!.sublist(0, _keyLength);
    _raw = _raw!.sublist(_keyLength);

    /// CR4-KSA
    for (var i = 0; i < data.length; i++) {
      data[i] ^= 0x64;
    }
    final aesDecrypted = _coreCryptor.decrypt(Encrypted(data), iv: _iv);
    final keyData = Uint8List.fromList(aesDecrypted.substring(17).codeUnits);
    return _decryptKey(keyData);
  }

  /// CR4-PRGA
  Uint8List _decryptKey(Uint8List raw) {
    final keyBox = List<int>.generate(256, (index) => index);
    var c = 0;
    var lastByte = 0;
    var keyOffset = 0;
    for (var i = 0; i < 256; i++) {
      var swap = keyBox[i];
      c = (swap + lastByte + raw[keyOffset]) & 0xff;
      keyOffset += 1;
      if (keyOffset >= raw.length) {
        keyOffset = 0;
      }

      keyBox[i] = keyBox[c];
      keyBox[c] = swap;
      lastByte = c;
    }

    return Uint8List.fromList(keyBox);
  }

  int _readMetaLength() {
    final data = _raw!.sublist(0, 4);
    _raw = _raw!.sublist(4);
    return data.getLength();
  }

  Meta _readMeta() {
    final data = _raw!.sublist(0, _metaLength);
    _raw = _raw!.sublist(_metaLength);

    for (var i = 0; i < _metaLength; i++) {
      data[i] ^= 0x63;
    }

    final b64Decoded = base64.decode(data.sublist(22).string);
    final aesDecrypted = _metaCryptor.decrypt(Encrypted(b64Decoded), iv: _iv);

    return Meta.fromJson(json.decode(aesDecrypted.substring(6)));
  }

  void _readCRC() {
    _raw = _raw!.sublist(4);
  }

  void _readGap() {
    _raw = _raw!.sublist(5);
  }

  int _readImageSize() {
    final data = _raw!.sublist(0, 4);
    _raw = _raw!.sublist(4);
    return data.getLength();
  }

  Uint8List _readImage() {
    final data = _raw!.sublist(0, _imageSize);
    _raw = _raw!.sublist(_imageSize);
    return data;
  }

  Uint8List _readMusic() {
    final music = List<int>.empty(growable: true);
    while (_raw!.length > 0) {
      final readLength = _raw!.length < musicChunkReadLength
          ? _raw!.length
          : musicChunkReadLength;
      var chunk = _raw!.sublist(0, readLength);
      _raw = _raw!.sublist(readLength);
      for (var i = 1; i < readLength + 1; i++) {
        final j = i & 0xff;
        chunk[i - 1] ^= key[(key[j] + key[(key[j] + j) & 0xff]) & 0xff];
      }
      music.addAll(chunk);
    }
    return Uint8List.fromList(music);
  }
}
