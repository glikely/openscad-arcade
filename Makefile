# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

all: example_2player_box.dxf

%.dxf: %.scad
	openscad -m make -o $@ -d $@.deps $<
