import 'dart:io';

// ===============================================================
// this copies libs to the applications .local/share folder for local testing
// needs paths package to get windows directory...

import 'package:path/path.dart' as p;

void main() {
  final projectDirPath = Directory.current.path;

  _copyLibraries(
    destDirPath: usersGptLibs(),
    projectDirPath: projectDirPath,
  );

  _copyLibraries(
    destDirPath: p.join(projectDirPath, builtDirectory()),
    projectDirPath: projectDirPath,
  );
}

void _copyLibraries({
  required String projectDirPath,
  required String destDirPath,
}) {
  final srcDir = Directory(p.join(projectDirPath, sourceDir())).absolute;
  final destDir = Directory(destDirPath).absolute;

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
      File(p.join(projectDirPath, sharedLibPath())).absolute;
  print('sharedLib: $dfcGptSharedLib');

  if (dfcGptSharedLib.existsSync()) {
    dfcGptSharedLib
        .copySync(p.join(destDir.path, p.basename(dfcGptSharedLib.path)));
  } else {
    print('### $sharedLibPath() doesnt exist');
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
        'Documents',
        'GitHub',
        'dfc',
        'dfc_gpt',
        'macos',
        'Libraries',
      );

    case 'windows':
      return p.join(
        homeDirectory(),
        'AppData/Roaming/re.distantfutu/deckr/gpt/libs',
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

String builtDirectory() {
  switch (Platform.operatingSystem) {
    case 'linux':
      return p.join(
        'shared_libs',
        'linux',
      );
    case 'macos':
      return p.join(
        'macos',
        'Libraries',
      );
    case 'windows':
      return p.join(
        'shared_libs',
        'windows',
      );
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

String sourceDir() {
  // relative to project directory
  const sourceDirectory = 'shared_libs/gpt4all/gpt4all-backend/build';

  switch (Platform.operatingSystem) {
    case 'linux':
      return sourceDirectory;
    case 'macos':
      return sourceDirectory;
    case 'windows':
      return '$sourceDirectory/bin/Release';
    default:
      print('### no sourceDir?');
      return '';
  }
}

String sharedLibPath() {
  // relative to project directory
  const sourceDirectory = 'shared_libs/dfc_gpt/build/install';

  // relative to project directory
  final filename = 'libdfc-gpt${libExt()}';

  switch (Platform.operatingSystem) {
    case 'linux':
      return '$sourceDirectory/lib/$filename';
    case 'macos':
      return '$sourceDirectory/lib/$filename';
    case 'windows':
      return '$sourceDirectory/bin/$filename';
    default:
      print('### no sourceDir?');
      return '';
  }
}
