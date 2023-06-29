build-runner:
	dart run build_runner build --delete-conflicting-outputs
	
lint:
	dart format .

dev:
	dart pub get
	make build-runner
	dart run bin/server.dart

build:
	docs/build.sh
	
clean:
	rm -rf build/	
	rm -rf stable-diffusion-webui-1.4.0/	

run:
	dart run bin/server.dart