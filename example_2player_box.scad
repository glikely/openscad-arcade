use <control_panel.scad>
//use <control_box.scad>

pconfig = [[6, "red", "sega2"],[6, "blue", "sega2"]];

size=[600,275,100];
//panel_drawings(size) {
	panel(size,pc=pconfig, r=1500, action="dimensions");
	panel(size,pc=pconfig, r=1500, action="add");
//}
//panel_box(angle=4, size=size,pc=pconfig, r=1500, show_controls=false);
