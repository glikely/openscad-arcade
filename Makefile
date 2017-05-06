# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

all: example_2player_box.dxf example_2player_box.svg

%.dxf: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut"' $<
%.svg: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="drawings"' $<
