#!/bin/bash

pushd "cppLib/dfc_gpt"

rm -r build
mkdir build
cd build
cmake ..
cmake --build . --parallel --config Release

# we install just to get the RPATH set correctly
cmake --install .

popd

dart './dart_tools/lib/copy_libraries.dart'

