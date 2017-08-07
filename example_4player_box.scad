use <control_panel.scad>

$fs=1;

pconfig = [[6, "green", "sega2", true],
           [], [], [], [],
           [6, "red", "sega2", true],
           [], [], [],
           [2, "white", "trackball", false],
           [], [], [],
           [6, "blue", "sega2", true],
           [], [], [], [],
           [6, "yellow", "sega2", true]];

size=[1200,340,100];

//OUTPUT_MODE = "lasercut";
OUTPUT_MODE = "full";

panel(size,pc=pconfig, r=2000, action=OUTPUT_MODE, cpu_window=true);
