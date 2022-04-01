## NCM Dump
Decrypt .ncm file and convert it to normal music format.
### Usage
```dart
final ncm = NCM();

final raw = await File('a.ncm').readAsBytes();
ncm.setRaw(raw);
ncm.parse();
await File('a.${ncm.meta.format}').writeAsBytes(ncm.music);
```


### Test
If you want to use your own `.ncm` file.  
Please copy your .ncm file to `test/assets/a.ncm`.  
And run the following command to test.
```bash
# convert .ncm to common music format
python3 test/ncmdumpy.py test/assets/a.ncm -o
# run dart test
dart test
```
