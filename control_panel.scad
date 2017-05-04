include <materials.scad>
use <utility.scad>
use <controls.scad>
use <dimlines.scad>

/**
 * panel_profile() - Creates a 2D outline of the control panel
 *
 * size: array of [width,height] describing the size of the panel
 * inset: (optional) array of [width,height] describing dimensions
 *        of the top edge of the panel if needed to fit inside a
 *        cabinet that is narrower than the control panel.
 * r: (optional) Radius of circle for a curved front control panel
 * corner: radius of corners on control panel, both for aesthetics
 *         and limitations of manufacturing process (ie. when using
 *         router to cut out the panel.
 */
module panel_profile(size, inset, r, corner=10, action="profile")
{
	// Calculate the front and back edge locations of the centre section
	curve_origin=r-size[1];
	back = inset ? inset[1] : 0;
	front = r ? sqrt(pow(r,2)-pow(size[0]/2,2)) - curve_origin : size[1];
	keystone = r ? (back+curve_origin)/(front+curve_origin) : 1;
	delta = r ? (size[0]/2)*(1 - (back+curve_origin)/(front+curve_origin)) : 0;

	if (action == "profile") round_corners(corner) {
		// Main block of panel. Might be trapezoidal
		polygon ([[-size[0]/2,-front], [size[0]/2,-front],
		          [size[0]/2-delta,-back], [-size[0]/2+delta,-back]]);

		// Optional curved front
		if (r) intersection() {
			translate([0,curve_origin,0]) circle(r,$fa=2);
			translate([-size[0]/2, -size[1]])
				square([size[0],size[1]-front+0.1]);
		}

		// Optional inset
		if (inset) {
			// Inset part of the panel
			translate([-inset[0]/2,-inset[1]-0.1,0])
				square([inset[0],inset[1]+0.1]);
		}
	}

	if (action == "dimensions") {
		// Angled Corners
		if (r) {
			panel_arc = asin((size[0]/2)/r)*2;
			mirror_dup([1,0,0]) {
				translate([0,curve_origin]) rotate([0,0,-90+panel_arc/2]) {
					translate([r,0]) {
						translate([-5,0]) line(18);
						rotate([0,0,90]) translate([-5,0])
							line(18);
					}
					translate([(size.x/2-delta)/sin(panel_arc/2)-10,0])
						line(13);
				}
				translate([size.x/2-delta-3, 0]) line(13);
			}
		}

		// Full panel width
		mirror_dup([1,0])
			translate([size.x/2,-size.y-25])
				rotate([0,0,90]) line(size.y-front+25);
		translate([-size.x/2,-size.y-20]) dimensions(size.x);
		// Angled panel width
		if (delta) {
			mirror_dup([1,0]) translate([size.x/2-delta,0])
				rotate([0,0,90]) line(25);
			translate([-size.x/2+delta,20])
				dimensions(size.x-delta*2);
		}

		// Full panel height
		if (r) {
			translate([size.x/2+5,-front]) line(25);
			translate([size.x/4,-size.y]) line(size.x/4+50);
			translate([size.x/2+25,-front]) rotate([0,0,90])
				dimensions(front);
		} else {
		}
		translate([size.x/2-delta,0]) line(delta+50);
		translate([size.x/2,-size.y]) line(50);
		translate([size.x/2+45,-size.y]) rotate([0,0,90]) dimensions(size.y);
	}
}

/* Some canned control cluster layouts */
player_config_1 = [[8, "red", "sega2"]];
player_config_2 = [[6, "red", "sega2"],
                   [6, "blue", "sega2"]];
player_config_2t =[[6, "red", "sega2"],
                   [0, "purple", "trackball"],
                   [6, "blue", "sega2"]];
player_config_3 = [[6, "red", "sega2"],
                   [6, "blue", "sega2"],
                   [6, "yellow", "sega2"]];
player_config_4 = [[4, "red", "sega2"],
                   [6, "blue", "sega2"],
                   [6, "green", "sega2"],
                   [4, "yellow", "sega2"]];
player_config_4t =[[4, "red", "sega2"],
                   [6, "blue", "sega2"],
                   [6, "purple", "trackball"],
                   [6, "green", "sega2"],
                   [4, "yellow", "sega2"]];

module panel_controls(size, r, action="add", start_spacing=120,
                      start_colour="white", pc=player_config_4,
                      coin_spacing=50, undermount=0, keepout_border=mdf_thick*1.5,
                      cluster_ypos=125)
{
	// '275' is loosely the width of a single control cluster.
	cluster_max_width=275;
	panel_arc = asin((size[0]/2)/r)*2;

	curve_origin=r-size[1];
	num_players = len(pc);

	// Player Start buttons
	translate([-start_spacing*(num_players-1)/2, -keepout_border - 30, 0])
		for (i=[0:num_players-1]) {
			translate([start_spacing*i-coin_spacing/2,0,0])
				button(color=start_colour, action=action, label="start");
			if (coin_spacing > 0)
				translate([start_spacing*i+coin_spacing/2,0,0])
					button(color=pc[i][1], action=action, label="coin");
		}

	// Game Controls
	for (idx=[0:len(pc)-1]) {
		p = pc[idx];
		offset = idx - (num_players-1)/2;
		if (r) {
			// Calculate the angle between control clusters, taking into
			// account the total panel width (on the curve), keeping the
			// clusters away from the sides, and the number of clusters
			// to place
			arc_length = ((2*PI*(r-cluster_ypos))*(panel_arc/360)) - cluster_max_width;
			arc_angle = 360 * arc_length/(2*PI*(r-cluster_ypos));
			cluster_angle = num_players > 1 ? arc_angle/(num_players-1) : 0;

			translate([0,curve_origin,0]) rotate([0,0,offset*cluster_angle])
				translate([0,-r+cluster_ypos ,0]) {
					control_cluster(undermount=undermount,
					                action=action,
					                max_buttons=p[0], color=p[1],
					                layout_name=p[2]);
				}

			if (action=="dimensions" && idx>0) translate([0,curve_origin])
				rotate([0,0,(offset-0.5)*cluster_angle-90])
					translate([curve_origin-10,0]) line(size[1]+20);
		} else {
			placement_width = size[0] - cluster_max_width;
			spacing = num_players > 1 ? placement_width/(num_players-1) : 0;
			translate([offset*spacing, -size[1]+cluster_ypos]) {
				control_cluster(undermount=undermount, action=action,
						max_buttons=p[0], color=p[1],
						layout_name=p[2]);
			}
		}
	}
}

module inset_profile(inset)
{
	minkowski() {
		difference() {
			square(10000, center=true);
			children();
		}
		circle(inset);
	}
}

default_layers = [
	[[0,0,1,.3], plex_thick, false],
	[FiberBoard, mdf_thick, true]
];

/**
 * panel_multilayer() - construct a panel out of multiple layers
 * layers: Array of layer descriptions. Each layer is a nested array containing
 *         layer colour and layer thickness (mm).
 * i: (do not use) internal iteration variable
 */
module panel_multilayer(layers=default_layers, i=0)
{
	layer_gap = 0.2;
	groove=[10,2]; // T-moulding groove depth & width
	if (i < len(layers)) {
		// Draw the bottom layers first on the assumption that the top
		// layer will be transparent. OpenSCAD Preview shows the right
		// thing if transparent items are added last.
		translate([0,0,-layers[i][1]-layer_gap])
			panel_multilayer(layers, i+1) children();

		// Add t-moulding groove
		color(layers[i][0]) difference() {
			// Add the layer
			translate([0,0,-layers[i][1]])
				linear_extrude(layers[i][1], convexity=10) children();
			if (layers[i][2]) {
				translate([0,0,-(layers[i][1]+groove[1])/2])
					linear_extrude(groove[1], convexity=10)
						inset_profile(groove[0]) children();
			}
		}
	}
}

// Default dimensions used for convenience in testing
default_size = [900, 400];
default_inset = [602, 125];
default_radius = 1000;

/**
 * panel() - Full control panel including multilayer board and control placement
 * size: array [width,height] of outside dimensions of the control panel
 * inset: (optional) array [width,height] of dimensions of inset section at
 *        back of panel (ie. to fit into cabinet narrower than control panel).
 * r: (optional) Radius of curve used for front edge of control panel. Use undef
 *    or 0 for no curve.
 */
module panel(size=default_size, inset, r=default_radius,
             pc=player_config_4, layers=default_layers,
             action="full")
{
	// Draw the controls first so that the if a transparent panel is used
	// then the OpenSCAD preview will show the controls behind the panel
	if (action == "full")
		panel_controls(size, r=r, pc=pc, undermount=plex_thick+0.1);

	// Draw placement guides
	if (action == "dimensions") color("black") {
		panel_controls(size, r=r, pc=pc, undermount=plex_thick+0.1,
		               action="dimensions");
		cutlines()
			translate([0,0,0.2])
				panel(size, inset, r, pc, layers, action="add");
		panel_profile(size, inset, r=r, action="dimensions");
	}

	// Carve the panel itself
	if (action == "full" || action == "add") {
		difference() {
			panel_multilayer(layers=layers)
				panel_profile(size, inset, r=r);
			panel_controls(size, r=r, pc=pc, undermount=plex_thick+0.1,
			               action="remove");
		}
	}

}

// Create manufacturing drawings by slicing the panel multiple times
module panel_drawings(size)
{
	slices = [-0.01/2,			// Dimensional lines
	          plex_thick/2,			// Plexiglass top layer
	          plex_thick+0.3,		// Top profile of MDF (inset cuts)
	          plex_thick+mdf_thick/2,	// Middle of MDF (through hole cuts)
	          plex_thick+mdf_thick-0.1];	// Bottom profile of MDF (inset cuts)

	projection(cut=true) {
		for (i=[0:len(slices)-1])
			translate([size[0]/2+10, (i+1)*(size[1]+10), slices[i]])
				children();
	}
}


test_radius=[0, 2000, 1000];
test_config=[
	[player_config_1, [602,300], undef],
	[player_config_2, [602,300], undef],
	[player_config_2t, [650,325], undef],
	[player_config_3, default_size, default_inset],
	[player_config_4, default_size, default_inset],
	//[player_config_4t, [1000,500], default_inset],
];

// Simpler layer setting for faster rendering.
simple_layers = [
	[FiberBoard, mdf_thick, false]
];


for (i=[0:len(test_radius)-1]) {
	xoff = (i-(len(test_radius)-1)/2)*default_size[0]*1.2;
	for (j=[0:len(test_config)-1]) {
		yoff = (j-(len(test_config)-1)/2)*default_size[1]*1.4;
		translate([xoff,yoff]) {
			panel(size=test_config[j][1],inset=test_config[j][2],
			      pc=test_config[j][0],trackball=test_config[j][3],
			      r=test_radius[i],action=(i==1 && j==2) ? "full" : "add",
			      layers=(i==1&&j==2) ? default_layers : simple_layers);
		}
	}
}
