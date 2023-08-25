import 'dart:io';

import 'package:path/path.dart' as p;

const kSourceDirectory =
    '/home/steve/Documents/GitHub/dfc/dfc_gpt/cppLib/chatlib/gpt4all/gpt4all-backend/build';
const kDestDirectory = '/home/steve/.local/share/re.distantfutu.deckr/gpt/libs';

const kDfcGptSharedLibFilename = 'dfc-gpt.so';
const kDfcGptSharedLibPath =
    '/home/steve/Documents/GitHub/dfc/dfc_gpt/cppLib/$kDfcGptSharedLibFilename';

// ===============================================================

void main() {
  final srcDir = Directory(kSourceDirectory).absolute;

  if (srcDir.existsSync()) {
    var files = srcDir.listSync(followLinks: false);

    files = files.where((e) => e.path.contains('.so')).toList();

    final destDir = Directory(kDestDirectory).absolute;

    // if dir exists, delete it and recreate
    if (destDir.existsSync()) {
      destDir.deleteSync(recursive: true);
    }
    destDir.createSync();

    // copy over our gpt-lib.so
    final dfcGptSharedLib = File(kDfcGptSharedLibPath).absolute;
    if (dfcGptSharedLib.existsSync()) {
      dfcGptSharedLib.copySync(p.join(destDir.path, kDfcGptSharedLibFilename));
    } else {
      print('$kDfcGptSharedLibFilename doesnt exist');
    }

    // set for symlinks
    Directory.current = destDir;

    for (final file in files) {
      if (file is Link) {
        final newLink = Link.fromUri(Uri.file(p.basename(file.path)));
        newLink.createSync(file.targetSync());
      } else if (file is File) {
        file.copySync(p.join(destDir.path, p.basename(file.path)));
      }
    }
  } else {
    print('### Error: could not find gpt build files');
  }
}
