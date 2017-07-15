include <materials.scad>
use <dimlines.scad>
use <utility.scad>

function panel_depth() = $panel_depth ? $panel_depth : 17;
function panel_undermount() = $panel_undermount ? $panel_undermount : plex_thick;

module button(color="red", action="add", label) {
	// Parameters
	screw_diameter = 23.8;
	screw_length = 31.2;
	button_diameter = 23.8;
	button_height = 12.6;
	switch_size=[6,24,18];
	fixingring_height = 10;
	fixingring_diameter = 33;

	// The button model
	if (action=="add") {
		color(color) {
			translate([0,0,-screw_length])
				cylinder(r=screw_diameter/2,h=screw_length);
			difference() {
				intersection() {
					cylinder(r=33.6/2,h=10.4);
					translate([0,0,-2])
						sphere(38/2);
				}
				translate([0,0,-1])
					cylinder(r=25/2,h=12);
			}

			translate([0,0,-screw_length]) cylinder(r=screw_diameter/2,h=screw_length);
			difference() {
				cylinder(r=button_diameter/2,h=button_height);
				translate([0,0,30])
					sphere(40/2);
			}
		}

		// Fixing Ring
		color(BlackPaint) translate([0, 0, -panel_depth()-fixingring_height]) {
			difference() {
				cylinder(r=fixingring_diameter/2, h=fixingring_height);
				translate([0,0,-0.1])
					cylinder(r=screw_diameter/2+0.1,
					         h=fixingring_height+0.2);
			}
		}

		translate([0, 0, - (screw_length + switch_size[2]/2 + 1)])
			color(BlackPaint)
				cube(switch_size, center=true);
	} else if (action=="remove") {
		// Dimensions for mounting hole. Right through all the layers
		// The +10 is to make sure the cut is all the way through the panel
		translate([0,0,-(screw_length+10)]) {
			cylinder(r=28/2, h=screw_length+10+button_height);
			cylinder(r=(fixingring_diameter+5)/2, h=10+10); // countersink for fixing ring
		}
	} else if (action=="dimensions") {
		circle_center(radius=28/2);
		if (label) translate([0,28/4,0]) scale_text()
			text(label, size=15, valign="center", halign="center");
	}
}

module sanwa_jlf_8s(color="red", action="add")
{
	shaft_len = 27.5+31.8+3.9;
	plate = [53,72,1.6];
	ear_inset = 8;
	ears = [53-0.01,107,1.6-0.01];
	bolthole_spacing = 107/2-6;
	bolthole_radius = 2.5;
	box = [75,61,33];
	tophole_radius = 10;

	if (action=="add") {
		// Ball top
		color(color) {
			translate([0,0,27.5+(32/2)]) sphere(34/2);
		}
		// shaft
		color("silver") translate([0,0,-shaft_len+28]) cylinder(r=4, h=shaft_len);

		// mounting plate
		color("silver") translate([0,0,-panel_depth()-plate.z]) {
			translate([0,0,ear_inset])
				cube(plate, center=true);
			difference() {
				cube(ears, center=true);
				cube(plate, center=true);
				translate([0,bolthole_spacing])
					cylinder(r=bolthole_radius, h=plate.z*2);
				translate([0,-bolthole_spacing])
					cylinder(r=bolthole_radius, h=plate.z*2);
			}
		}

		// Electronics box
		color(BlackPaint) translate([0,0,-panel_depth()-plate.z+ear_inset-(box[2]/2)])
			cube(box, center=true);

		// Dust Cover Disc
		color("black") cylinder(r=18, h=0.5);

	} else if (action=="remove") translate([0,0,-panel_depth()-0.1]) {
		// The cutouts for the joystick
		// Hole for the joystick box
		translate([0,0,ear_inset-(box[2]+3)/2])
			cube([box[0],plate[1],box[2]+3], center=true);
		// Mounting holes
		translate([0,bolthole_spacing,0])
			cylinder(r=bolthole_radius, h=panel_depth()-panel_undermount());
		translate([0,-bolthole_spacing,0])
			cylinder(r=bolthole_radius, h=panel_depth()-panel_undermount());

		// Round hole for joystick shaft
		translate([0,0,0]) cylinder(r=tophole_radius, h=panel_depth()+0.2);
	} else if (action=="dimensions") {
		circle_center(radius=tophole_radius);
	}
}

module joystick(color="red", action="add")
{
	shaft_len = 27.5+31.8+3.9;
	plate = [65,97,1.6];
	boltholes = [22,41];
	box = [60,55,31.8];
	ears = [20,box[1]+12*2,10];
	tophole_radius = 10;

	if (action=="add") {
		translate([0,0,-panel_undermount()]) {
			// Ball top
			color(color) {
				translate([0,0,27.5+(32/2)]) sphere(34/2);
			}
			// shaft
			color("silver") translate([0,0,-shaft_len+28]) cylinder(r=4, h=shaft_len);

			// mounting plate
			color("silver") translate([0,0,-2/2]) difference() {
				cube(plate, center=true);
				fourcorners() translate(boltholes) rotate([0,0,45]) hull() {
					translate([0,-2,-1]) cylinder(r=3, h=plate.z*2);
					translate([0, 2,-1]) cylinder(r=3, h=plate.z*2);
				}
			}

			// Electronics box
			color(BlackPaint) translate([0,0,-2-(box[2]/2)])
				cube(box, center=true);
			color(BlackPaint) translate([0,0,-2-(ears[2]/2)])
				cube(ears, center=true);
		}
		// Dust Cover Disc
		color("black") cylinder(r=18, h=0.5);

	} else if (action=="remove") translate([0,0,-panel_undermount()]) {
		// The cutouts for the joystick
		// Mount place profile
		translate([0,0,-2/2]) cube([plate[0]+5, plate[1]+5, 2], center=true);
		// Hole for the joystick box
		translate([0,0,-(box[2]/2 + 3)])
			cube([box[0],box[1],box[2]+6], center=true);
		// Mounting holes
		translate([0,0,-(box[2] + 6)]) fourcorners()
			translate([22,41]) cylinder(r=2, h=box[2]+6);
		translate([0,0,-(box[2]/2 + 3)])
			cube([ears[0],ears[1],box[2]+6], center=true);

		// Round hole for joystick shaft
		translate([0,0,-2/2]) cylinder(r=tophole_radius, h=10);
	} else if (action=="dimensions") {
		circle_center(radius=tophole_radius);
		fourcorners() translate([22,41]) circle_center(radius=2);
	}
}

// utrak_mounts() - private utility for placing mounting holes
module utrak_mounts(spacing = 81.32)
{
	d=sqrt(2*pow(spacing/2,2));
	for (p=[[d,0],[-d,0],[0,d],[0,-d]])
		translate(p)
			children();
}

module utrak_trackball(action="add")
{
	box_width = 145;
	box_height = 53;
	diag_length = 176;
	diag_width = 126.5;
	hole_spacing = 81.32;
	hole_radius = 5/2;
	housing_height = 19;
	housing_radius = 82/2;
	flang_height = 2;
	flang_radius = housing_radius + 5;

	if (action=="add") translate([0,0,-panel_depth()]) {
		// Housing
		color(BlackPaint) difference() {
			translate([0,0,-box_height/2-0.1]) intersection() {
				cube([box_width,box_width,box_height], center=true);
				rotate([0,0,45])
					cube([diag_width,diag_length,box_height], center=true);
			}
			// Bolt holes
			utrak_mounts()
				translate([0,0,-box_height-0.1])
					cylinder(r=hole_radius, h=box_height+0.2);
		}
		color(BlackPaint) difference() {
			union() {
				cylinder(r=housing_radius,h=housing_height);
				if (panel_depth() <= 17.5)
					translate([0,0,19-flang_height])
						cylinder(r=flang_radius,h=flang_height);
			}
			translate([0,0,-0.1]) {
				cylinder(r=housing_radius-2,h=housing_height+0.1-flang_height);
				cylinder(r=housing_radius-5,h=housing_height+0.2);
			}
		}
		// Trackball
		translate([0,0,0]) color([1,0,1,0.75]) sphere(3/2 * 25.4);
	} else if (action=="remove") {
		translate([0,0,-panel_depth()-box_height/2-0.5]) intersection() {
			cube([box_width+5,box_width+5,box_height], center=true);
			// FIXME - The following two lines should be
			// uncommented, but it confuses OpenSCAD. In the mean
			// time leave it out and live with a larger than
			// necessary inset profile
			//rotate([0,0,45])
			//	cube([diag_width+5,diag_length+5,box_height], center=true);
		}
		cylinder(r=housing_radius, h=box_height + panel_depth());
		// Bolt holes
		utrak_mounts()
			cylinder(r=hole_radius, h=box_height/2+panel_depth()-2.1);
	} else if (action=="dimensions") {
		circle_center(housing_radius, size=housing_radius/4);
		utrak_mounts()
			circle_center(hole_radius);
	}
}

module cpu_96boards(action="add", margin=10, bs=[85,54])
{
	if (action == "add") {
		translate([-bs.x/2,-bs.y,-(panel_depth()+10)])
			color("green") difference() {
				cube([bs.x, bs.y, 1]);
				translate([5,5,-0.1]) cylinder(r=2,h=2);
				translate([bs.x-5,5,-0.1]) cylinder(r=2,h=2);
				translate([5,bs.y-5,-0.1]) cylinder(r=2,h=2);
				translate([bs.x-5,bs.y-5,-0.1]) cylinder(r=2,h=2);
			}
		translate([-bs.x/2,-bs.y*2-10,-(panel_depth()+10)])
			color("green") difference() {
				cube([bs.x, bs.y, 1]);
				translate([5,5,-0.1]) cylinder(r=2,h=2);
				translate([bs.x-5,5,-0.1]) cylinder(r=2,h=2);
				translate([5,bs.y-5,-0.1]) cylinder(r=2,h=2);
				translate([bs.x-5,bs.y-5,-0.1]) cylinder(r=2,h=2);
			}
	} else if (action=="remove") {
		translate([0,-bs.y/2,-(panel_depth()+10)])
			linear_extrude(panel_depth()+10 - panel_undermount())
				offset(r=margin) square(bs, center=true);
	} else if (action=="dimensions") {
		scale_text() text("96Boards Display Window", halign="center");
	}
}

// Some of these layouts come from and use the same names as
// http://www.slagcoin.com/joystick/layout.html
layouts = [
	["matrix36",["joystick", [-95,0]],
	          ["button",  [  0,-18],[  0,18],
	                      [ 36,-18],[ 36,18],
	                      [ 72,-18],[ 72,18],
	                      [108,-18],[108,18]]],
	["sega1", ["joystick", [-59,0]],
	          ["button",  [0,       -14],[7,             -14+38.5],
	                      [33,        0],[33+7,              38.5],
	                      [33+36,    -6],[33+36+6.5,      -6+38.5],
	                      [33+36+34,-21],[33+36+34+6.5,-6-15+38.5]]],
	["sega2", ["joystick",[-59,0]],
	          ["button",  [0,          -20],[0,           19],
	                      [30.5,         0],[30.5,        39],
	                      [30.5+36,      0],[30.5+36,     39],
	                      [30.5+36+35.5,-9],[30.5+36+35.5,30]]],
	["hori36",["joystick",[-59,0]],
	          ["button",  [0,        -27],[0,           9],
	                      [31.25,     -9],[31.25,      27],
	                      [31.25+35,   0],[31.25+35,   36],
	                      [31.25+35+36,0],[31.25+35+36,36]]],
	["trackball",  ["utrak", [0,0]]],
	["trackball2", ["utrak", [0,0]],
	               ["button", [-20, 100], [20,100]]],
	["trackball3", ["utrak", [0,0]],
	               ["button", [100, -40], [110,0], [100,40]]]
];

module control_cluster(color="red", layout_name="sega2",
                       action="add", max_buttons=8)
{
	size=[200,125];
	layout = layouts[search([layout_name], layouts)[0]];

	// Find and place list of buttons
	btns=layout[search(["button"], layout)[0]];
	for(p=[1:len(btns)-1])
		if (p <= max_buttons)
			translate(btns[p]) button(color, action=action); // 1st bottom

	// Find and place joysticks
	joy=layout[search(["joystick"], layout)[0]];
	for(p=[1:len(joy)-1])
		translate(joy[p]) joystick(color, action=action);

	// Find and place trackballs
	track=layout[search(["utrak"], layout)[0]];
	for(p=[1:len(track)-1])
		translate(track[p]) utrak_trackball(action=action);

	if (action=="dimensions") {
		translate([-size[0]/2-10,size[1]/2])
			line(size[0]+20);
		translate([-size[0]/2-10,-size[1]/2])
			line(size[0]+20);
		translate([-size[0]/2,-size[1]/2-10])
			rotate([0,0,90])line(size[1]+20);
		translate([size[0]/2,-size[1]/2-10])
			rotate([0,0,90])line(size[1]+20);
	}
}

// Demonstration code. Show each of the default layouts
test_spacing=300;
$panel_undermount = 0;
for (idx=[0:len(layouts)-1]) {
	translate([test_spacing*(idx-len(layouts)/2+0.5),0,0]) {
		layout = layouts[idx];
		layout_name = layout[0];
		translate([0,-100]) color("black") scale_text()
			text(layout_name, halign="center");
		translate([0,-1000]) {
			control_cluster(layout_name=layout_name, max_buttons=4);
			color([0,0,1,1]) difference() {
				translate([0,0,-20/2-0.1])
					cube([test_spacing-25,225,20], center=true);
				control_cluster(layout_name=layout_name,
				                action="remove", max_buttons=4);
			}
		}
		translate([0,-750]) {
			control_cluster(layout_name=layout_name, max_buttons=6);
			color([0,0,1,1]) difference() {
				translate([0,0,-20/2-0.1])
					cube([test_spacing-25,225,20], center=true);
				control_cluster(layout_name=layout_name,
				                action="remove", max_buttons=6);
			}
		}
		translate([0,-500]) control_cluster(layout_name=layout_name);
		translate([0,-250]) {
			control_cluster(layout_name=layout_name);
			color([0,0,1,1]) difference() {
				translate([0,0,-20/2-0.1])
					cube([test_spacing-25,225,20], center=true);
				control_cluster(layout_name=layout_name,
				                action="remove");
			}
		}
		translate([0,0]) {
			control_cluster(layout_name=layout_name);
			color([0,0,1,0.3]) difference() {
				translate([0,0,-20/2-0.1])
					cube([test_spacing-25,225,20], center=true);
				control_cluster(layout_name=layout_name,
				                action="remove");
			}
		}
		translate([0,250]) color([0,0,1,0.3]) {
			control_cluster(layout_name=layout_name, action="guide");
			difference() {
				translate([0,0,-20/2-0.1])
					cube([test_spacing-25,225,20], center=true);
				control_cluster(layout_name=layout_name,
				                action="remove");
			}
		}
		translate([0,500]) control_cluster(layout_name=layout_name,
		                                   action="remove");
	}
}
