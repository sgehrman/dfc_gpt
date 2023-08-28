cmake_minimum_required(VERSION 3.7)
project(dfc_gpt)

set(CMAKE_CXX_COMPILER /usr/bin/clang++)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# make windows match linux with a lib prefix
if(WIN32)
    set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
    set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
endif()

if(WIN32 OR APPLE)
    set(CMAKE_CXX_STANDARD 23)
endif()

add_library(library
  SHARED 
  main.cpp 
  ${CMAKE_SOURCE_DIR}/include/dart_api_dl.c
)

target_link_directories(library
  PRIVATE 
  ${CMAKE_SOURCE_DIR}/../chatlib/gpt4all/gpt4all-backend/build/Release
)
 
set_target_properties(library 
  PROPERTIES
  OUTPUT_NAME "dfc-gpt"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)

if(WIN32)
  target_link_libraries(library llmodel)
else()
  target_link_libraries(library libllmodel)
endif()
