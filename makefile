all: lint format-check

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
