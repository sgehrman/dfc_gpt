#!/bin/bash

flutter pub upgrade --major-versions --tighten

cd ./tools/dart_tools
flutter pub upgrade --major-versions --tighten

echo '## all done'
