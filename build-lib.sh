#!/bin/bash

pushd "cppLib/dfc_gpt"

rm -r build
mkdir build
cd build
cmake ..
cmake --build . --parallel

cp ./build/libdfc-gpt.so /home/steve/.local/share/re.distantfutu.deckr/gpt/libs/

popd

