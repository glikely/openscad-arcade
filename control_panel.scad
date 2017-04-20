include <materials.scad>
use <controls.scad>

// Top panel
module panel_profile(size, inset, r)
{
	difference() {
		intersection() {
			translate([-size[0]/2,-size[1],0])
				square(size);
			if (r)
				translate([0,r-size[1],0])
					circle(r);
		}
		if (inset) union() {
			translate([inset[0]/2,-inset[1],0])
				square([(size[0] - inset[0])/2+1, inset[1]+1]);
			translate([-(size[0]/2+1),-inset[1],0])
				square([(size[0] - inset[0])/2+1, inset[1]+1]);
		}
	}
}

player_config_1 = [[8, "red", "sega2"]];
player_config_2 = [[6, "red", "sega2"],
                   [6, "blue", "sega2"]];
player_config_3 = [[6, "red", "sega2"],
                   [6, "blue", "sega2"],
                   [6, "yellow", "sega2"]];
player_config_4 = [[4, "red", "sega2"],
                   [6, "blue", "sega2"],
                   [6, "green", "sega2"],
                   [4, "yellow", "sega2"]];
player_config_5 = [[4, "red", "sega2"],
                   [6, "blue", "sega2"],
                   [6, "purple", "trackball3"],
                   [6, "green", "sega2"],
                   [4, "yellow", "sega2"]];

module panel_controls(size, r, cutout=false, start_spacing=120,
                      start_colour="white", pc=player_config_4,
                      coin_spacing=50, trackball=true, undermount=0)
{
	curve_origin=r-size[1];
	num_players = len(pc);
	spacing = (size[0]-50)/num_players;
	curve_angle = asin((spacing/2)/(r-100))*2;

	// Player Start buttons
	translate([-start_spacing*(num_players-1)/2, -75, 0])
		for (i=[0:num_players-1]) {
			translate([start_spacing*i-coin_spacing/2,0,0]) {
				button(color=start_colour, cutout=cutout);
				translate([0,-40,0]) text("start", halign="center");
			}
			if (coin_spacing > 0) {
				translate([start_spacing*i+coin_spacing/2,0,0]) {
					button(color=pc[i][1], cutout=cutout);
					translate([0,-40,0]) text("coin", halign="center");
				}
			}
		}

	// Game Controls
	for (idx=[0:len(pc)-1]) {
		p = pc[idx];
		offset = idx - (num_players-1)/2;
		if (r) {
			translate([0,curve_origin,0]) rotate([0,0,offset*curve_angle])
				translate([0,-r+100 ,0]) {
					control_cluster(undermount=undermount,
						   cutout=cutout,
						   max_buttons=p[0], color=p[1], layout_name=p[2]);
					// Guide lines
					rotate([0,90,0]) square([1, r]);
				}
		} else {
			translate([offset*spacing, -size[1]+100])
				control_cluster(undermount=undermount, cutout=cutout,
						max_buttons=p[0], color=p[1]);
		}
	}

	if (trackball)
		translate([0,-size[1]/2,0]) utrak_trackball(cutout=cutout);
}

module panel_multilayer(layers=[[[0,0,1,.3], plex_thick],
                                [FiberBoard, mdf_thick]], i=0)
{
	if (i < len(layers)) {
		// Draw the bottom layers first on the assumption that the top
		// layer will be transparent. OpenSCAD Preview shows the right
		// thing if transparent items are added last.
		translate([0,0,-layers[i][1]-0.2])
			panel_multilayer(layers, i+1) children();
		// Add the layer
		color(layers[i][0]) translate([0,0,-layers[i][1]])
			linear_extrude(layers[i][1], convexity=10) children();
	}
}

// Default dimensions used for convenience in testing
default_size = [900, 450];
default_inset = [602, 150];
default_radius = 1000;

module panel(size=default_size, inset=default_inset, r=default_radius, pc=player_config_4) {
	panel_controls(size, r=r, pc=pc, undermount=plex_thick+0.1);
	difference() {
		panel_multilayer() panel_profile(size, inset, r=r);
		panel_controls(size, r=r, pc=pc, undermount=plex_thick+0.1, cutout=true);
	}
}

rad=[undef,2000,1000,800];
for (idx=[1:1]) {
	xoff = (idx-1)*(default_size[0])*1.2;
	//translate([xoff,-1*default_size[1]*1.2,0]) panel(pc=player_config_2,r=rad[idx]);
	translate([xoff,0*default_size[1]*1.2,0]) panel(pc=player_config_4,r=rad[idx]);
	//translate([xoff,1*default_size[1]*1.2,0]) panel(pc=player_config_3,r=rad[idx]);
}
//projection(cut=true) translate([0,0,plex_thick/2]) panel();
//projection(cut=true) translate([0,0,plex_thick+0.3]) panel();
//projection(cut=true) translate([0,0,plex_thick+mdf_thick]) panel();
