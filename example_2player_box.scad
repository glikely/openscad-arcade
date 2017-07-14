use <control_panel.scad>

pconfig = [[6, "red", "sega2", true],
           [6, "blue", "sega2", true]];

size=[600,275,100];

OUTPUT_MODE = "full";

panel(size,pc=pconfig, r=1500, action=OUTPUT_MODE);
