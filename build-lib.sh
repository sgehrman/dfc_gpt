#!/bin/bash

pushd "cppLib/dfc_gpt"

rm -r build
mkdir build
cd build
cmake ..
cmake --build . --parallel

popd

# copy it to the libs dir
pushd "cppLib/dfc_gpt"

cp ./build/libdfc-gpt.so ~/.local/share/re.distantfutu.deckr/gpt/libs/

popd

