#!/bin/bash

export CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda
export CUDACXX=/usr/local/cuda/bin/nvcc

# https://vulkan.lunarg.com/sdk/home#linux
# https://vulkan.lunarg.com/doc/sdk/1.3.296.0/linux/getting_started.html
export VULKAN_SDK=~/vulkan/1.3.296.0/x86_64
export PATH=$VULKAN_SDK/bin:$PATH
export LD_LIBRARY_PATH=$VULKAN_SDK/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export VK_LAYER_PATH=$VULKAN_SDK/share/vulkan/explicit_layer.d

pushd "shared_libs/gpt4all/gpt4all-backend"

rm -rf build
mkdir build
cd build
cmake ..
cmake --build . --parallel --config Release

popd

dart './tools/dart_tools/lib/copy_libraries.dart'
