include <materials.scad>
use <controls.scad>

/**
 * corner_rounding() - Helper module for rounding square corners
 * r: Radius of corner rounding
 *
 * Can be used to produce rounded corners by taking difference with outside
 * corners, and taking union with inside corners.
 */
module corner_rounding(r)
{
	if (r) difference() {
		square([r*2,r*2], center=true);
		translate([ r, r]) circle(r);
		translate([-r, r]) circle(r);
		translate([ r,-r]) circle(r);
		translate([-r,-r]) circle(r);
	}
}

/**
 * rounded_panel() - 2D square module with rounded corners
 * keystone: Scaling factor for the size of the top edge to create a
 *           keystone shape.
 */
module rounded_panel(size, r, keystone=1)
{
	delta = size[0]*(1 - keystone)/2;
	if (r) hull() {
		translate([r,r]) circle(r);
		translate([size[0]-r,r]) circle(r);
		translate([size[0]-r-delta,size[1]-r]) circle(r);
		translate([r+delta,size[1]-r]) circle(r);
	} else {
		square(size);
	}
}

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
module panel_profile(size, inset, r, corner=10)
{
	// Calculate the front and back edge locations of the centre section
	back = inset ? inset[1] : 0;
	front = r ? sqrt(pow(r-corner,2)-pow(size[0]/2-corner,2)) + corner - (r-size[1]) : size[1];
	keystone = r ? (back+(r-size[1]))/(front+(r-size[1])) : 1;

	hull() {
		translate([-size[0]/2,-front,0])
			rounded_panel([size[0],front-back],corner,keystone=keystone);

		if (r) intersection() {
			translate([0,r-size[1],0]) circle(r,$fa=2);
			translate([-size[0]/2+corner, -size[1]])
				square([size[0]-corner*2,size[1]-front+5]);
		}
	}

	if (inset) {
		// Inset part of the panel
		translate([-inset[0]/2,-(inset[1]+corner),0])
			rounded_panel([inset[0], inset[1]+corner],corner);

		// Inside corner rounding between inset and center panel
		translate([-inset[0]/2,-inset[1]]) corner_rounding(corner);
		translate([ inset[0]/2,-inset[1]]) corner_rounding(corner);
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
                      coin_spacing=50, undermount=0, keepout_border=mdf_thick*1.5)
{
	// '250' is loosly the width of a single control cluster.
	cluster_max_width=250;

	curve_origin=r-size[1];
	num_players = len(pc);

	// Player Start buttons
	translate([-start_spacing*(num_players-1)/2, -keepout_border - 30, 0])
		for (i=[0:num_players-1]) {
			translate([start_spacing*i-coin_spacing/2,0,0]) {
				button(color=start_colour, action=action);
				translate([0,-40,0]) text("start", halign="center");
			}
			if (coin_spacing > 0) {
				translate([start_spacing*i+coin_spacing/2,0,0]) {
					button(color=pc[i][1], action=action);
					translate([0,-40,0]) text("coin", halign="center");
				}
			}
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
			panel_arc = asin((size[0]/2)/r)*2;
			arc_length = ((2*PI*(r-100))*(panel_arc/360)) - cluster_max_width;
			arc_angle = 360 * arc_length/(2*PI*(r-100));
			cluster_angle = num_players > 1 ? arc_angle/(num_players-1) : 0;

			translate([0,curve_origin,0]) rotate([0,0,offset*cluster_angle])
				translate([0,-r+100 ,0]) {
					control_cluster(undermount=undermount,
					                action=action,
					                max_buttons=p[0], color=p[1],
					                layout_name=p[2]);
					// Guide lines
					if (action=="guide")
						rotate([0,90,0]) square([1, r]);
				}
		} else {
			placement_width = size[0] - cluster_max_width;
			spacing = num_players > 1 ? placement_width/(num_players-1) : 0;
			translate([offset*spacing, -size[1]+100]) {
				control_cluster(undermount=undermount, action=action,
						max_buttons=p[0], color=p[1],
						layout_name=p[2]);
				if (action=="guide")
					rotate([0,90,0]) square([1, 200]);
			}
		}
	}
}

/**
 * panel_multilayer(): construct a panel out of multiple layers
 * layers: Array of layer descriptions. Each layer is a nested array containing
 *         layer colour and layer thickness (mm).
 * i: (do not use) internal iteration variable
 */
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
default_size = [900, 400];
default_inset = [602, 150];
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
             pc=player_config_4, show_controls=true)
{
	if (show_controls)
		panel_controls(size, r=r, pc=pc, undermount=plex_thick+0.1);
	difference() {
		panel_multilayer()
			panel_profile(size, inset, r=r);
		panel_controls(size, r=r, pc=pc, undermount=plex_thick+0.1,
		               action="remove");
	}
}

// Create manufacturing diagrams by slicing the panel multiple times
module panel_drawings()
{
	slices = [plex_thick/2, plex_thick+0.3,
	          plex_thick+mdf_thick/2, plex_thick+mdf_thick-0.1];

	projection(cut=true) for (i=[0:len(slices)-1]) {
		translate([900, (i+1)*500, slices[i]]) children();
	}
}

test_radius=[0, 2000, 1000];
test_config=[
	[player_config_1, [602,300], undef],
	[player_config_2, [602,275], undef],
	[player_config_2t, [650,300], undef],
	[player_config_3, default_size, default_inset],
	[player_config_4, default_size, default_inset],
	//[player_config_4t, [1000,500], default_inset],
];

for (i=[0:len(test_radius)-1]) {
	xoff = (i-(len(test_radius)-1)/2)*default_size[0]*1.2;
	for (j=[0:len(test_config)-1]) {
		yoff = (j-(len(test_config)-1)/2)*default_size[1]*1.4;
		translate([xoff,yoff])
			panel(size=test_config[j][1],inset=test_config[j][2],
			      pc=test_config[j][0],trackball=test_config[j][3],
			      r=test_radius[i],show_controls=(i==1 && j==2));
	}
}
