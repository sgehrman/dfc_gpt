#!/bin/bash

pushd "shared_libs/dfc_gpt"

rm -rf build
mkdir build
cd build

# added to compile on laptop, see also ./shared_libs/dfc_gpt/CMakeLists.txt - needed for atomic
# $ sudo apt install gcc-12
export CC=/usr/bin/gcc-12
export CXX=/usr/bin/g++-12

cmake ..
cmake --build . --parallel --config Release

# we install just to get the RPATH set correctly
cmake --install .

popd

dart './tools/dart_tools/lib/copy_libraries.dart'

