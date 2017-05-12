# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

all: example_2player_box-plex.dxf example_2player_box-3mm.dxf example_2player_box-6mm.dxf example_2player_box.svg

%-6mm.dxf: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut-6mm"' $<
%-3mm.dxf: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut-3mm"' $<
%-plex.dxf: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut-plex"' $<
%-plex.svg: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut-plex"' $<
%.svg: %.scad
	openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="drawings"' $<
