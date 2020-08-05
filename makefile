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
	cd godot-cpp && scons platform=linux target=release generate_bindings=yes && cd ..

build:
	scons platform=x11 target=release

clean:
	scons platform=x11 target=release -c
