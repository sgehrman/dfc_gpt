
rm -r gpt4all_source
mkdir gpt4all_source

pushd "gpt4all_source"

git clone --recurse-submodules https://github.com/nomic-ai/gpt4all

popd
 

# ====================================================================
# if you get a fresh copy of gpt4all, change the make file before building
# otherwise the mac builds will be compiled for macOS 13
# also, we don't want libxx.0.3.dylib, so remove the version numbers for macOS (at least)
# cppLib/chatlib/gpt4all/gpt4all-backend/CMakeLists.txt

# add this to top of file
# set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "" FORCE)

# comment these out
# set_target_properties(llmodel PROPERTIES
#                               VERSION ${PROJECT_VERSION}
#                               SOVERSION ${PROJECT_VERSION_MAJOR})

 