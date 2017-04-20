include <materials.scad>
use <controls.scad>

// Default dimensions used for convenience in testing
default_size = [1000, 550];
default_inset = [602, 150];

curve_radius = 500;
curve_angle = asin((default_size[0]/2 - 275)/curve_radius);

// Top panel
module panel_profile(size, inset)
{
	difference() {
		intersection() {
			translate([-size[0]/2,-size[1],0])
				square(size);
			translate([0,curve_radius-size[1]+150,0])
				circle(r=curve_radius+150);
		}
		if (inset) union() {
			translate([inset[0]/2,-inset[1],0])
				square([(size[0] - inset[0])/2+1, inset[1]+1]);
			translate([-(size[0]/2+1),-inset[1],0])
				square([(size[0] - inset[0])/2+1, inset[1]+1]);
		}
	}
}

player_config_1 = [[0, 8, red]];
player_config_2 = [[-curve_angle*0.5, 6, red],
                   [ curve_angle*0.5, 6, blue]];
player_config_3 = [[-curve_angle, 6, red],
                   [           0, 6, blue],
                   [ curve_angle, 6, yellow]];
player_config_4 = [[-curve_angle*1.5, 4, red],
                   [-curve_angle*0.5, 6, blue],
                   [ curve_angle*0.5, 6, green],
                   [ curve_angle*1.5, 4, yellow]];

module panel_controls(size, cutout=false, start_spacing=120,
                      start_colour="white", player_config=player_config_4,
                      coin_spacing=50, trackball=true, undermount=0)
{
	num_players = len(player_config);

	// Player Start buttons
	translate([-start_spacing*(num_players-1)/2, -75, 0])
		for (i=[0:num_players-1]) {
			translate([start_spacing*i-coin_spacing/2,0,0]) {
				button(color=start_colour, cutout=cutout);
				translate([0,-40,0]) text("start", halign="center");
			}
			if (coin_spacing > 0) {
				translate([start_spacing*i+coin_spacing/2,0,0]) {
					button(color=player_config[i][2], cutout=cutout);
					translate([0,-40,0]) text("coin", halign="center");
				}
			}
		}

	// Game Controls
	translate([0,curve_radius-size[1]+100,0]) {
		for (p=player_config)
			rotate([0,0,p[0]]) translate([0,-curve_radius,0])
				control_cluster(undermount=undermount,
				           cutout=cutout,
				           max_buttons=p[1], color=p[2]);
	}

	if (trackball)
		translate([0,-size[1]+300,0]) utrak_trackball(cutout=cutout);
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

module panel(size=default_size, inset=default_inset) {
	panel_controls(size, undermount=plex_thick+0.1);
	difference() {
		panel_multilayer() panel_profile(size, inset);
		panel_controls(size, undermount=plex_thick+0.1, cutout=true);
	}
}

panel();
//projection(cut=true) translate([0,0,plex_thick/2]) panel();
//projection(cut=true) translate([0,0,plex_thick+0.3]) panel();
//projection(cut=true) translate([0,0,plex_thick+mdf_thick]) panel();
