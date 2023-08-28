#!/bin/bash

pushd "cppLib/dfc_gpt"

rm -r build
mkdir build
cd build
cmake ..
cmake --build . --parallel

popd

dart './dart_tools/lib/copy_libraries.dart'

