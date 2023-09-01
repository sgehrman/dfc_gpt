pushd "shared_libs/gpt4all/gpt4all-backend"

rm -r build
mkdir build
cd build
cmake ..
cmake --build . --parallel --config Release

popd

dart './tools/dart_tools/lib/copy_libraries.dart'
