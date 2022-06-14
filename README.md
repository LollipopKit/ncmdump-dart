## NCM Dump
Decrypt .ncm file and convert it to normal music format.
### Usage
```dart
final ncm = NCM();

final raw = await File('a.ncm').readAsBytes();
ncm.parse(raw);
await File('a.${ncm.meta.format}').writeAsBytes(ncm.music);
```


### Test
Please copy your .ncm file to `test/assets/a.ncm`.  
And run the following command to test.
```bash
# convert .ncm to common music format
python3 test/ncmdumpy.py test/assets/a.ncm -o
# run dart test
dart test
```
