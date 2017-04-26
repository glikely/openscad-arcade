include <materials.scad>

undermount_depth = 3;

module button(color="red", action="add") {
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
		color(BlackPaint) translate([0, 0, -screw_length]) difference() {
			cylinder(r=fixingring_diameter/2, h=fixingring_height);
			translate([0,0,-0.1])
				cylinder(r=screw_diameter/2+0.1, h=fixingring_height+0.2);
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
	} else if (action=="guide") {
		rotate([90,0,0]) square([screw_diameter*1.2,1],center=true);
		rotate([0,90,0]) square([1,screw_diameter*1.2],center=true);
		circle(3);
	}
}

module joystick(color="red", undermount=0, action="add") {
	shaft_len = 27.5+31.8+3.9;
	plate_width = 65;
	plate_height = 97;

	if (action=="add") {
		translate([0,0,-undermount]) {
			// Ball top
			color(color) {
				translate([0,0,27.5+(32/2)]) sphere(34/2);
			}
			// shaft
			color("silver") translate([0,0,-shaft_len+28]) cylinder(r=4, h=shaft_len);

			// mounting plate
			color("silver") translate([0,0,-2/2]) cube([plate_width, plate_height, 1.6], center=true);

			// Electronics box
			color(BlackPaint) translate([0,0,-2-(31.8/2)]) cube([50,50,31.8], center=true);
		}
		// Dust Cover Disc
		color("black") cylinder(r=18, h=0.5);

	} else if (action=="remove") translate([0,0,-undermount]) {
		// The cutouts for the joystick
		// Mount place profile
		translate([0,0,-2/2]) cube([plate_width+5, plate_height+5, 2], center=true);
		// Hole for the joystick box
		translate([0,0,-(32/2 + 2)]) cube([55,55,32+1], center=true);

		// Round hole for joystick shaft
		translate([0,0,-2/2]) cylinder(r=10, h=10);
	} else if (action=="guide") {
		rotate([90,0,0]) square([32*1.2,1],center=true);
		rotate([0,90,0]) square([1,32*1.2],center=true);
		difference() {
			circle(16);
			circle(3);
		}
	}
}

module utrak_trackball(undermount=17, action="add")
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

	if (action=="add") translate([0,0,-undermount]) {
		// Housing
		color(BlackPaint) difference() {
			translate([0,0,-box_height/2-0.1]) intersection() {
				cube([box_width,box_width,box_height], center=true);
				rotate([0,0,45])
					cube([diag_width,diag_length,box_height], center=true);
			}
			// Bolt holes
			for (i=[0:3])
				rotate([0,0,45+90*i])
					translate([hole_spacing/2,hole_spacing/2,-box_height-0.1])
						cylinder(r=hole_radius, h=box_height+0.2);
		}
		color(BlackPaint) difference() {
			union() {
				cylinder(r=housing_radius,h=housing_height);
				if (undermount <= 17)
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
	} else if (action=="remove") translate([0,0,-undermount-box_height/2]) {
		intersection() {
			cube([box_width+5,box_width+5,box_height], center=true);
			//rotate([0,0,45])
				//cube([diag_width+5,diag_length+5,box_height], center=true);
		}
		cylinder(r=housing_radius, h=box_height + undermount);
		// Bolt holes
		for (i=[0:3])
			rotate([0,0,45+90*i])
				translate([hole_spacing/2,hole_spacing/2,0])
					cylinder(r=hole_radius, h=box_height/2+undermount-2.1);
	} else if (action=="guide") {
		rotate([90,0,0]) square([housing_radius*2.4,1],center=true);
		rotate([0,90,0]) square([1,housing_radius*2.4],center=true);
		difference() {
			circle(housing_radius);
			circle(3);
		}
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
	["trackball3", ["utrak", [0,0]],
	               ["button", [100, -40], [110,0], [100,40]]]
];

module control_cluster(color="red", undermount=0, layout_name="sega2",
                       action="add", max_buttons=8)
{
	layout = layouts[search([layout_name], layouts)[0]];

	// Find and place list of buttons
	btns=layout[search(["button"], layout)[0]];
	for(p=[1:len(btns)-1])
		if (p <= max_buttons)
			translate(btns[p]) button(color, action=action); // 1st bottom

	// Find and place joysticks
	joy=layout[search(["joystick"], layout)[0]];
	for(p=[1:len(joy)-1])
		translate(joy[p]) joystick(color, undermount=undermount, action=action);

	// Find and place trackballs
	track=layout[search(["utrak"], layout)[0]];
	for(p=[1:len(track)-1])
		translate(track[p]) utrak_trackball(action=action);
}

// Demonstration code. Show each of the default layouts
test_spacing=300;
for (idx=[0:len(layouts)-1]) {
	translate([test_spacing*(idx-len(layouts)/2+0.5),0,0]) {
		layout = layouts[idx];
		layout_name = layout[0];
		translate([0,-100]) color("black") text(layout_name, 12, halign="center");
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
