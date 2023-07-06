@echo off
rmdir /S build
mkdir build
cd build
mkdir ssdc_companion_server
cd ..
@echo on

copy .env.example build\ssdc_companion_server\
copy bin\isar.dll build\ssdc_companion_server\
copy README.md build\ssdc_companion_server\
mkdir build\ssdc_companion_server\isar\
copy isar\.gitkeep build\ssdc_companion_server\isar\

dart compile exe bin/server.dart --target-os windows -o build/ssdc_companion_server/ssdc_companion_server_windows.exe
