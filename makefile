all: tests lint format-check

.PHONY: tests
tests:
	godot-server -d -s --path ../../ addons/gut/gut_cmdln.gd -gprefix='Test' -gdir=res://addons/sconys-godot-utilities/tests/ -gexit 2>/dev/null

cloc:
	cloc .

gource:
	gource . --key -s 1.5 -a 0.1

format:
	find -name '*.gd' | xargs gdformat

format-check:
	find -name '*.gd' | xargs gdformat --check

lint:
	find -name '*.gd' | xargs gdlint

setup:
	godot --gdnative-generate-json-api api.json
	cd godot-cpp && scons platform=linux generate_bindings=yes && cd ..

build:
	g++ -fPIC -o bin/GeometryNG.o -c native/GeometryNG.cpp -g -O3 -std=c++14 -Igodot-cpp/include -Igodot-cpp/include/core -Igodot-cpp/include/gen -Igodot-cpp/godot_headers
	g++ -o bin/libaddon.so -shared bin/GeometryNG.o -Lgodot-cpp/bin -lgodot-cpp.linux.debug.64
