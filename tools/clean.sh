#!/bin/bash

flutter clean

cd ./tools/dart_tools
flutter clean
cd $OLDPWD

# get pubs again
./tools/pub.sh

echo '## all done'
