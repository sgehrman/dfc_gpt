#!/bin/bash

libs="/home/steve/Documents/GitHub/dfc/dfc_gpt/cppLib/chatlib/gpt4all/gpt4all-backend/build"

dic="/home/steve/Documents/GitHub/dfc/dfc_gpt/cppLib/include/dart_api_dl.c"

# make shared lib
clang++ -shared -o dfc-gpt.so main.cpp $libs/libllmodel.so -x c $dic -Wl,-rpath,"$libs" -fPIC

cp ./dfc-gpt.so /home/steve/.local/share/re.distantfutu.deckr/gpt/libs/
