#!/bin/bash

clang++ -v    main.cpp   /home/steve/expr/cpplus/chatlib/gpt4all/gpt4all-backend/build/libllmodel.so  -Wl,-rpath,"/home/steve/expr/cpplus/chatlib/gpt4all/gpt4all-backend/build/"
# g++ main.cpp

# ./a.out