#!/bin/bash

rm -rf build/
mkdir build/
mkdir build/ssdc_companion_server/

# Build Dart package
dart compile exe bin/server.dart --target-os macos -o build/ssdc_companion_server/ssdc_companion_server_macos
dart compile exe bin/server.dart --target-os linux -o build/ssdc_companion_server/ssdc_companion_server_linux

cp .env.example build/ssdc_companion_server/
cp bin/libisar.dylib build/ssdc_companion_server/
cp bin/libisar.so build/ssdc_companion_server/
cp README.md build/ssdc_companion_server/

zip -r build/ssdc_companion_server.zip build/