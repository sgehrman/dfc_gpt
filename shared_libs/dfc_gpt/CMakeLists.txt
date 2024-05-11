cmake_minimum_required(VERSION 3.7)
project(dfc_gpt)

# updated to compile on laptop, see also ./tools/build-lib.sh - needed for atomic
# $ sudo apt install gcc-12
set(CMAKE_CXX_COMPILER /usr/bin/g++)
# set(CMAKE_CXX_COMPILER /usr/bin/g++-12)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "" FORCE)

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)

if(APPLE)
  set(CMAKE_INSTALL_RPATH @loader_path)
else() 
  set(CMAKE_INSTALL_RPATH $ORIGIN)
endif()

# assuming this is needed. It's in the gpt4all make file
if(APPLE)
  option(BUILD_UNIVERSAL "Build a Universal binary on macOS" ON)
  if(BUILD_UNIVERSAL)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "" FORCE)
  else()
    if(NOT CMAKE_OSX_ARCHITECTURES)
      set(CMAKE_OSX_ARCHITECTURES "${CMAKE_HOST_SYSTEM_PROCESSOR}" CACHE STRING "" FORCE)
    endif()
  endif()
endif()

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
  # links with Release .libs? not bin/Release?
  set(GPT_BUILD_LOCATION "build/Release") 
else() 
  set(GPT_BUILD_LOCATION "build")
endif()

target_link_directories(library
  PRIVATE 
  ${CMAKE_SOURCE_DIR}/../gpt4all/gpt4all-backend/${GPT_BUILD_LOCATION}
)

set_target_properties(library 
  PROPERTIES
  OUTPUT_NAME "dfc-gpt"
  XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)

target_link_libraries(library llmodel)

install(TARGETS library)
