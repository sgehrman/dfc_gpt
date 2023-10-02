#!/bin/bash

flutter pub outdated --no-transitive

cd ./tools/dart_tools
flutter pub outdated --no-transitive

echo '### all done'
