pushd "cppLib/chatlib"

# git clone --recurse-submodules https://github.com/nomic-ai/gpt4all

cd gpt4all/gpt4all-backend/

rm -r build
mkdir build
cd build
cmake ..
cmake --build . --parallel --config Release

popd

dart './dart_tools/lib/copy_libraries.dart'
