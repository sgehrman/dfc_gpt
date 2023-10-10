#!/bin/bash

echo ' '
echo '-----------------------------------------------'
echo "#### Building gptall" 
./tools/build-gpt4all.sh

echo ' '
echo '-----------------------------------------------'
echo "#### Building lib" 
./tools/build-lib.sh

echo ' '
echo '-----------------------------------------------'
echo "#### Build all done" 
