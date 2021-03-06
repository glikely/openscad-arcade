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
module panel_profile(size, inset, r, corner=10, mount_angle, action="profile")
{
	// Calculate the front and back edge locations of the centre section
	curve_origin=r-size[1];
	back = inset ? inset[1] : 0;
	front = r ? sqrt(pow(r,2)-pow(size[0]/2,2)) - curve_origin : size[1];
	keystone = r ? (back+curve_origin)/(front+curve_origin) : 1;
	delta = r ? (size[0]/2)*(1 - (back+curve_origin)/(front+curve_origin)) : 0;
	panel_arc = r ? asin((size[0]/2)/r)*2 : 0;

	if (action == "profile") round_corners(corner) {
		// Main block of panel. Might be trapezoidal
		polygon ([[-size[0]/2,-front], [size[0]/2,-front],
		          [size[0]/2-delta,-back], [-size[0]/2+delta,-back]]);

		// Optional curved front
		if (r) intersection() {
			//echo(str("Panel Arc: ", panel_arc, "°"));
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

	if (action == "frame") {
		height = size.z - panel_depth();
		ffront = size[1] - 33;
		a = [size[0]/2-delta-10, -back];
		b = [a.x+(front-mdf_thick*2.25-back)*tan(panel_arc/2), -front+mdf_thick*2.25];
		c = [b.x-(ffront+b.y)/tan(panel_arc/2), -ffront];
		polygon ([[-a.x,a.y],[-b.x,b.y],[-c.x,c.y],c,b,a]);

		// Print out the frame board dimensions
		side_len = sqrt(pow(b.x-a.x,2)+pow(b.y-a.y,2));
		frontlr_len = sqrt(pow(c.x-b.x,2)+pow(c.y-b.y,2));
		echo("Frame board dimensions");
		echo(str("Rear: length=", a.x*2, "mm ",
		               "height=", height, "mm ",
		               "mitre=", (90-panel_arc/2)/2, " ",
		               "slope=", mount_angle));
		echo(str("Side: length=", side_len, "mm ",
		         "height(top,bottom)=", height, ",", height - tan(mount_angle) * (-b.y),"mm ",
		         "mitre=", (90-panel_arc/2)/2, ",", 90/2, " deg ",
		         "slope=", atan(tan(mount_angle)*cos(panel_arc/2)), " ",
		         "bevel=", atan(tan(mount_angle)*sin(panel_arc/2))));
		echo(str("Front L/R: length=", frontlr_len, "mm ",
		         "height(top,bottom)=", height - tan(mount_angle) * (-b.y), ",", height - tan(mount_angle) * (-c.y),"mm ",
		         "mitre=", (90/2), ",", panel_arc/2/2, " deg ",
		         "slope=", atan(tan(mount_angle)*sin(panel_arc/2)), " ",
		         "bevel=", atan(tan(mount_angle)*cos(panel_arc/2))));
		echo(str("Front C:   length=", c.x*2, "mm height=", height - tan(mount_angle) * (-c.y), "mm ",
		         "mitre=", panel_arc/2/2, " slope=", mount_angle));
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

module frame_extrude(frame_height, frame_thickness=21)
{
	translate([0,0,-frame_height]) linear_extrude(frame_height, convexity=10) difference() {
		children();
		offset(-frame_thickness) children();
	}
}

/* Some canned control cluster layouts */
player_config_1 = [[8, "red", "sega2", true]];
player_config_2 = [[6, "red", "sega2", true],
                   [6, "blue", "sega2", true]];
player_config_2t =[[6, "red", "sega2", true],
                   [0, "purple", "trackball", false],
                   [6, "blue", "sega2", true]];
player_config_3 = [[6, "red", "sega2", true],
                   [6, "blue", "sega2", true],
                   [6, "yellow", "sega2", true]];
player_config_4 = [[4, "red", "sega2", true],
                   [6, "blue", "sega2", true],
                   [6, "green", "sega2", true],
                   [4, "yellow", "sega2", true]];
player_config_4t =[[4, "red", "sega2", true],
                   [6, "blue", "sega2", true],
                   [6, "purple", "trackball2", false],
                   [6, "green", "sega2", true],
                   [4, "yellow", "sega2", true]];

module panel_controls(size, inset, r, action="add",
                      start_colour="white", pc=player_config_4,
                      coin_spacing=40, keepout_border=mdf_thick,
                      cluster_ypos=125, cpu_window=false)
{
	// '275' is loosely the width of a single control cluster.
	cluster_max_width=275;
	panel_arc = asin((size[0]/2)/r)*2;

	curve_origin=r-size[1];
	num_players = len(pc);

	// Values for control cluster placement
	placement_width = size[0] - cluster_max_width;
	spacing = num_players > 1 ? placement_width/(num_players-1) : 0;

	// Values for start/select button placement
	start_ypos = -(keepout_border+28);
	start_spacing = inset ? (inset[0]-coin_spacing*2)/num_players : spacing;

	// CPU Board Window
	if (cpu_window) translate([0,-keepout_border-10])
		cpu_96boards(action=action);

	// Game Controls
	for (idx=[0:len(pc)-1]) if (pc[idx]) {
		p = pc[idx];
		offset = idx - (num_players-1)/2; // idx adjusted to center == 0
		if (r) {
			// Calculate the angle between control clusters, taking into
			// account the total panel width (on the curve), keeping the
			// clusters away from the sides, and the number of clusters
			// to place
			arc_length = ((2*PI*(r-cluster_ypos))*(panel_arc/360)) - cluster_max_width;
			arc_angle = 360 * arc_length/(2*PI*(r-cluster_ypos));
			cluster_angle = num_players > 1 ? arc_angle/(num_players-1) : 0;
			player_angle = cluster_angle * offset;
			start_xpos = (curve_origin-start_ypos)*tan(player_angle);

			// Place start/select buttons
			if (p[3] && !inset) translate([start_xpos, start_ypos, 0]) {
				translate([-coin_spacing/2,0,0])
					button(color=start_colour, action=action, label="select");
				if (coin_spacing)
					translate([coin_spacing/2,0,0])
						button(color=p[1], action=action, label="start");
			}

			translate([0,curve_origin]) rotate([0,0,player_angle])
				translate([0,-r+cluster_ypos]) {
					control_cluster(action=action,
					                max_buttons=p[0], color=p[1],
					                layout_name=p[2]);
				}

			if (action=="dimensions") translate([0,curve_origin])
				rotate([0,0,player_angle-90])
					translate([curve_origin-10,0]) {
						line(size[1]+20);
						translate([50,0])scale_text()
							text(str("Angle: ", player_angle, "°"), valign="bottom");
					}
		}

		// Player Start buttons
		if (p[3] && (!r || inset)) {
			start_xpos = start_spacing*offset;
			translate([start_xpos-coin_spacing/2, start_ypos])
				button(color=start_colour, action=action, label="select");
			if (coin_spacing) translate([start_xpos+coin_spacing/2, start_ypos])
				button(color=p[1], action=action, label="start");
		}

		if (!r) {
			translate([offset*spacing, -size[1]+cluster_ypos]) {
				control_cluster(action=action,
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

layer_gap = 0.01;
default_layers = [
	[[0,0,1,.3], plex_thick, 0], // 3mm Perspex topsheet
	[[0,0,0], layer_gap*3, 0], // Vinyl Graphic Overlay
	[FiberBoard, 6, 0, -90],   // MDF Top (6mm)
	[FiberBoard, 2, -8,-18], // MDF Middle (2mm) with t-moulding groove
	[FiberBoard, 6, 0, 80],   // MDF Bottom (6mm)
];

function layer_depth(layers=default_layers, n, i=0) =
		(i < len(layers)) && (n != i) ?
			layers[i][1] + layer_depth(layers, n, i+1) :
			0;

/**
 * panel_multilayer() - construct a panel out of multiple layers
 * layers: Array of layer descriptions. Each layer is a nested array containing
 *         layer colour and layer thickness (mm).
 * distribute: vector to dispurse layers so each one can be seen individually
 */
module panel_multilayer(layers=default_layers, distribute=[0,0,0], action="add")
{

	// Draw the bottom layers first on the assumption that the top
	// layer will be transparent. OpenSCAD Preview shows the right
	// thing if transparent items are added last.
	for (i = [len(layers)-1:-1:0]) translate(i * distribute) {
		//echo("doing layer", i, "depth", layer_depth(layers, n=i+1));
		layer = layers[i];

		// Add the layer
		if (action == "add") color(layer[0]) difference() {
			translate([0,0,-layer_depth(layers, n=i+1)+layer_gap])
				linear_extrude(layer[1]-layer_gap*2, convexity=10)
					offset(r=layer[2])
						children([0]);
			children([1]);
		}

		if (action == "lasercut") jigsaw_cut(layer[3]) difference() {
			offset(r=layer[2]) children([0]);
			// Trim the negative object to only this layer
			projection() intersection() {
				translate([-1000,-1000,-layer_depth(layers, n=i+1)+layer_gap])
					cube([2000,2000,layer[1]-layer_gap*2]);
				children([1]);
			}
		}

		if (action == "dimensions") cutlines() difference() {
			offset(r=layer[2]) children([0]);
			// Trim the negative object to only this layer
			projection() intersection() {
				translate([-1000,-1000,-layer_depth(layers, n=i+1)+layer_gap])
					cube([2000,2000,layer[1]-layer_gap*2]);
				children([1]);
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
             action="full", cpu_window=false, mount_angle=3)
{
	$panel_depth = layer_depth(layers);
	$panel_window_depth = layer_depth(layers, n=1);
	$panel_mount_depth = layer_depth(layers, n=2);

	// Draw the controls first so that the if a transparent panel is used
	// then the OpenSCAD preview will show the controls behind the panel
	if (action == "full")
		rotate([mount_angle,0,0])
		panel_controls(size, inset, r, pc=pc, cpu_window=cpu_window);

	// Draw placement guides
	if (action == "dimensions") color("black") {
		panel_controls(size, inset, r, pc=pc,
		               cpu_window=cpu_window, action="dimensions");
		panel_profile(size, inset, r=r, action="dimensions");
		panel_multilayer(layers=layers, action="dimensions") {
			panel_profile(size, inset, r=r);
			panel_controls(size, inset, r, pc=pc,
			               cpu_window=cpu_window, action="remove");
		}
	}

	// Carve the panel itself
	if (action == "full" || action == "add" || action == "lasercut") {
		rotate([mount_angle,0,0])
		panel_multilayer(layers=layers, distribute=(action == "lasercut") ? [0,350,0] : 0,
		                 action=(action == "lasercut") ? "lasercut" : "add") {
			panel_profile(size, inset, r=r);
			panel_controls(size, inset, r, pc=pc,
			               cpu_window=cpu_window, action="remove");
		}
		translate([0,0,-panel_depth()]) difference() {
			frame_height = size.z - panel_depth();
			frame_extrude(frame_height)
				panel_profile(size, inset, r=r, action="frame", mount_angle=mount_angle);
			rotate([mount_angle,0,0]) translate([-size.x/2,-size.y]) cube([size.x, size.y, frame_height]);
		}
	}
}

test_radius=[0, 2000, 1000];
test_config=[
	[player_config_1, [602,300], undef, false],
	[player_config_2, [602,300], undef, false],
	[player_config_2t, [650,325], undef, true],
	[player_config_3, default_size, default_inset, false],
	[player_config_4, default_size, default_inset, false],
	//[player_config_4t, [1000,500], default_inset],
];

// Simpler layer setting for faster rendering.
simple_layers = [
	[FiberBoard, mdf_thick, 0]
];


for (i=[0:len(test_radius)-1]) {
	xoff = (i-(len(test_radius)-1)/2)*default_size[0]*1.2;
	for (j=[0:len(test_config)-1]) {
		tc = test_config[j];
		yoff = (j-(len(test_config)-1)/2)*default_size[1]*1.4;
		translate([xoff,yoff]) {
			panel(size=tc[1], inset=tc[2], pc=tc[0], trackball=tc[3],
			      r=test_radius[i],action=(i==1 && j==2) ? "full" : "add",
			      layers=(i==1&&j==2) ? default_layers : simple_layers,
			      cpu_window=tc[3]);
		}
	}
}
