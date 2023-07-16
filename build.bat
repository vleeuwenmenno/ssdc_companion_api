@echo off
rmdir /S build
mkdir build
cd build
mkdir ssdc_companion_ui
cd ..
@echo on

copy README.md build\ssdc_companion_ui\

flutter build windows -o build/ssdc_companion_ui/