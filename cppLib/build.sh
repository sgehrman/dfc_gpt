#!/bin/bash

libs="/home/steve/Documents/GitHub/dfc/dfc_gpt/cppLib/chatlib/gpt4all/gpt4all-backend/build"

clang++ main.cpp $libs/libllmodel.so -Wl,-rpath,"$libs"
# g++ main.cpp

# ./a.out