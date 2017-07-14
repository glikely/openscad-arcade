# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

all: example_2player_box-plex.dxf example_2player_box-2mm.dxf example_2player_box-6mm.dxf example_2player_box.svg example_2player_box-vinyl.svg joystick_adapters.dxf

%-6mm.dxf: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut-6mm"' $<
%-2mm.dxf: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut-2mm"' $<
%-plex.dxf: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut-plex"' $<
%-vinyl.svg: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="vinyl"' $<
%.svg: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="drawings"' $<
%.dxf: %.scad
	openscad -m make -o $@ -d $@.deps $<
