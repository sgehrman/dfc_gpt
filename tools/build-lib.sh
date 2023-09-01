#!/bin/bash

pushd "shared_libs/dfc_gpt"

rm -r build
mkdir build
cd build
cmake ..
cmake --build . --parallel --config Release

# we install just to get the RPATH set correctly
cmake --install .

popd

dart './tools/dart_tools/lib/copy_libraries.dart'

