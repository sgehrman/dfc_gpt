cmake_minimum_required(VERSION 3.7)
project(dfc_gpt)

set(CMAKE_CXX_COMPILER /usr/bin/g++)
set(CMAKE_CXX_STANDARD 23)

# make windows match linux with a lib prefix
if(WIN32)
    set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
    set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
endif()

add_library(library
  SHARED 
  main.cpp 
  ${CMAKE_SOURCE_DIR}/include/dart_api_dl.c
)

if(WIN32)
  set(GPT_BUILD_LOCATION "build/bin/Release")
else() 
  set(GPT_BUILD_LOCATION "build")
endif()

target_link_directories(library
  PRIVATE 
  ${CMAKE_SOURCE_DIR}/../chatlib/gpt4all/gpt4all-backend/${GPT_BUILD_LOCATION}
)
 
set_target_properties(library 
  PROPERTIES
  OUTPUT_NAME "dfc-gpt"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)

target_link_libraries(library llmodel)
