pushd "chatlib"

git clone --recurse-submodules https://github.com/nomic-ai/gpt4all
cd gpt4all/gpt4all-backend/
mkdir build
cd build
cmake ..
cmake --build . --parallel

popd