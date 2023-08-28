import 'dart:io';

// ===============================================================
// this copies libs to the applications .local/share folder for local testing
// needs paths package to get windows directory...

import 'package:path/path.dart' as p;

// relative to project directory
const kSourceDirectory = 'cppLib/chatlib/gpt4all/gpt4all-backend/build';

// relative to home directory
const kLinuxDestDirectory = '.local/share/re.distantfutu.deckr/gpt/libs';

const kDfcGptSharedLibFilename = 'libdfc-gpt.so';

// relative to project directory
const kDfcGptSharedLibPath = 'cppLib/dfc_gpt/build/$kDfcGptSharedLibFilename';

// ===============================================================

void main() {
  final homeDir = homeDirectory();
  final projectDir = Directory.current.path;

  final srcDir = Directory(p.join(projectDir, kSourceDirectory)).absolute;
  final destDir = Directory(p.join(homeDir, kLinuxDestDirectory)).absolute;

  print('src: $srcDir');
  print('destDir: $destDir');

  // if dir exists, delete it and recreate
  if (destDir.existsSync()) {
    destDir.deleteSync(recursive: true);
  }
  destDir.createSync();

  if (srcDir.existsSync()) {
    // set for symlinks
    Directory.current = destDir;

    // copy any .so, .dll, .dylib it can find in the gpt4all build folder
    var files = srcDir.listSync(followLinks: false);
    files = files.where((e) => e.path.contains('.so')).toList();

    for (final file in files) {
      if (file is Link) {
        final newLink = Link.fromUri(Uri.file(p.basename(file.path)));
        newLink.createSync(file.targetSync());
      } else if (file is File) {
        file.copySync(p.join(destDir.path, p.basename(file.path)));
      }
    }
  } else {
    print('### Error: could not find srcDir');
  }

  // copy over our gpt-lib.so
  final dfcGptSharedLib =
      File(p.join(projectDir, kDfcGptSharedLibPath)).absolute;
  print('sharedLib: $dfcGptSharedLib');

  if (dfcGptSharedLib.existsSync()) {
    dfcGptSharedLib.copySync(p.join(destDir.path, kDfcGptSharedLibFilename));
  } else {
    print('$kDfcGptSharedLibFilename doesnt exist');
  }
}

String homeDirectory() {
  switch (Platform.operatingSystem) {
    case 'linux':
    case 'macos':
      return Platform.environment['HOME'] ?? '';
    case 'windows':
      return Platform.environment['USERPROFILE'] ?? '';
    default:
      return '';
  }
}
