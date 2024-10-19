#!/bin/bash

export CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda
export CUDACXX=/usr/local/cuda/bin/nvcc

# https://vulkan.lunarg.com/sdk/home#linux
# https://vulkan.lunarg.com/doc/sdk/1.3.296.0/linux/getting_started.html
export VULKAN_SDK=~/vulkan/1.3.296.0/x86_64
export PATH=$VULKAN_SDK/bin:$PATH
export LD_LIBRARY_PATH=$VULKAN_SDK/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export VK_LAYER_PATH=$VULKAN_SDK/share/vulkan/explicit_layer.d

pushd "shared_libs/dfc_gpt"

rm -rf build
mkdir build
cd build

# added to compile on laptop, see also ./shared_libs/dfc_gpt/CMakeLists.txt - needed for atomic
# $ sudo apt install gcc-12
# export CC=/usr/bin/gcc-12
# export CXX=/usr/bin/g++-12
# export CC=/usr/bin/gcc
# export CXX=/usr/bin/g++

# did this to set 12 as default
# $ sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 20
# $ sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 20


cmake ..
cmake --build . --parallel --config Release

# we install just to get the RPATH set correctly
cmake --install .

popd

dart './tools/dart_tools/lib/copy_libraries.dart'

