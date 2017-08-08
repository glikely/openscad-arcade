# explicit wildcard expansion suppresses errors when no files are found
include $(wildcard *.deps)

2player: example_2player_box-lasercut.svg example_2player_box-lasercut.dxf example_2player_box.svg
4player: example_4player_box-lasercut.svg example_4player_box-lasercut.dxf example_4player_box.svg

%-lasercut.dxf: %.scad
	time openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut"' $<
%-lasercut.svg: %.scad
	time openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="lasercut"' $<
%.svg: %.scad
	time openscad -m make -o $@ -d $@.deps -D 'OUTPUT_MODE="dimensions"' $<
