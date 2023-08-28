import 'dart:io';

// ===============================================================
// this copies libs to the applications .local/share folder for local testing
// needs paths package to get windows directory...

import 'package:path/path.dart' as p;

// relative to project directory
const kSourceDirectory = 'cppLib/chatlib/gpt4all/gpt4all-backend/build';

// relative to project directory
const kDfcGptSharedLibFilename = 'libdfc-gpt.so';
const kDfcGptSharedLibPath = 'cppLib/dfc_gpt/build/$kDfcGptSharedLibFilename';

// ===============================================================

void main() {
  final projectDir = Directory.current.path;

  final srcDir = Directory(p.join(projectDir, kSourceDirectory)).absolute;
  final destDir = Directory(usersGptLibs()).absolute;

  print('### COPYING: $srcDir');
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
    files = files.where((e) => e.path.contains(libExt())).toList();

    for (final file in files) {
      if (file is Link) {
        final newLink = Link.fromUri(Uri.file(p.basename(file.path)));
        newLink.createSync(file.targetSync());
      } else if (file is File) {
        file.copySync(p.join(destDir.path, p.basename(file.path)));
      }

      print(' - copied: ${p.basename(file.path)}');
    }
  } else {
    print('### Error: could not find srcDir');
  }

  // copy over our libgpt-lib.so
  final dfcGptSharedLib =
      File(p.join(projectDir, kDfcGptSharedLibPath)).absolute;
  print('sharedLib: $dfcGptSharedLib');

  if (dfcGptSharedLib.existsSync()) {
    dfcGptSharedLib
        .copySync(p.join(destDir.path, p.basename(dfcGptSharedLib.path)));
  } else {
    print('### $kDfcGptSharedLibFilename doesnt exist');
  }
}

String usersGptLibs() {
  switch (Platform.operatingSystem) {
    case 'linux':
      return p.join(
        homeDirectory(),
        '.local/share/re.distantfutu.deckr/gpt/libs',
      );

    case 'macos':
      return p.join(
        homeDirectory(),
        '?????',
      );

    case 'windows':
      return p.join(
        homeDirectory(),
        '?????',
      );
    default:
      print('### no home?');
      return '';
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
      print('### no home?');
      return '';
  }
}

String libExt() {
  switch (Platform.operatingSystem) {
    case 'linux':
      return '.so';
    case 'macos':
      return '.dylib';
    case 'windows':
      return '.dll';
    default:
      print('### no lib ext?');
      return '';
  }
}
