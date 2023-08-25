import 'dart:io';

import 'package:path/path.dart' as p;

const kDeployBuildDirectory = 'tools/deploy/build';
const kGptLibsBundleDirectory = '$kDeployBuildDirectory/bundle';
// const kGptLibsArchivePath = '$kDeployBuildDirectory/gpt-libs.tar.gz';

const kGpt4AllBuildDirectory =
    '../dfc_gpt/cppLib/chatlib/gpt4all/gpt4all-backend/build';
const kDfcGptSharedLibFilename = 'dfc-gpt.so';
const kDfcGptSharedLibPath = '../dfc_gpt/cppLib/$kDfcGptSharedLibFilename';

// ===============================================================

void main() {
  final gpt4AllBuildDir = Directory(kGpt4AllBuildDirectory).absolute;
  final dfcGptSharedLib = File(kDfcGptSharedLibPath).absolute;

  if (dfcGptSharedLib.existsSync() && gpt4AllBuildDir.existsSync()) {
    final deployBuildDir = Directory(kDeployBuildDirectory).absolute;

    // if dir exists, delete it and recreate
    if (deployBuildDir.existsSync()) {
      deployBuildDir.deleteSync(recursive: true);
    }
    deployBuildDir.createSync();

    final bundleDir = Directory(kGptLibsBundleDirectory).absolute;
    bundleDir.createSync();

    dfcGptSharedLib.copySync(p.join(bundleDir.path, kDfcGptSharedLibFilename));

    // copy all .so files from gpt4all build dir
    var files = gpt4AllBuildDir.listSync(followLinks: false);

    files = files.where((e) => e.path.contains('.so')).toList();

    // set for symlinks
    Directory.current = bundleDir;

    for (final file in files) {
      if (file is Link) {
        final newLink = Link.fromUri(Uri.file(p.basename(file.path)));
        newLink.createSync(file.targetSync());
      } else if (file is File) {
        file.copySync(p.join(bundleDir.path, p.basename(file.path)));
      }
    }
  } else {
    print('### Error: could not find gpt build files');
  }
}
