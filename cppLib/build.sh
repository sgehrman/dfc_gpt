#!/bin/bash

libs="/home/steve/Documents/GitHub/dfc/dfc_gpt/cppLib/chatlib/gpt4all/gpt4all-backend/build"

# make shared lib
clang++ -shared -o xx.so main.cpp $libs/libllmodel.so -Wl,-rpath,"$libs" -fPIC

# create app
clang++ ./xx.so  

# run app
# ./a.out