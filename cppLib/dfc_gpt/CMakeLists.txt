cmake_minimum_required(VERSION 3.7)
project(dfc_gpt)

set(CMAKE_CXX_COMPILER /usr/bin/clang++)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_library(library
  SHARED 
  main.cpp 
  ${CMAKE_SOURCE_DIR}/include/dart_api_dl.c
)

target_link_directories(library
  PRIVATE 
  ${CMAKE_SOURCE_DIR}/../chatlib/gpt4all/gpt4all-backend/build
)
 
set_target_properties(library 
  PROPERTIES
  OUTPUT_NAME "dfc-gpt"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)

target_link_libraries(library libllmodel.so)
