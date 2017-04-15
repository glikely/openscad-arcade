include <materials.scad>

undermount_depth = 3;

module button(color=red, cutout=false) {
	// Parameters
	screw_diameter = 23.8;
	screw_length = 31.2;
	button_diameter = 23.8;
	button_height = 12.6;
	switch_length = 6;
	switch_width = 24;
	switch_height = 18;

	// The button model
	if (!cutout) {
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

		translate([0, 0, - (screw_length + switch_height/2 + 1)])
			color(black)
				cube([switch_length, switch_width, switch_height], center = true);
	} else union() {
		// Dimensions for mounting hole. Right through all the layers
		translate([0,0,-(screw_length+10)]) {
			cylinder(r=28/2, h=screw_length+10+button_height);
			cylinder(r=40/2, h=20); // contersink for nuts
		}
	}
}

module joystick(color=red, cutout=false) {
	shaft_len = 27.5+31.8+3.9;
	plate_width = 65;
	plate_height = 97;

	if (!cutout) {
		// Ball top
		color(color) {
			translate([0,0,27.5+(32/2)]) sphere(34/2);
		}
		// shaft
		color(silver) translate([0,0,-shaft_len+28]) cylinder(r=4, h=shaft_len);

		// Disc
		color(black) translate([0,0,plex_thick]) cylinder(r=18, h=0.5);

		// mounting plate
		color(silver) translate([0,0,-2/2]) cube([plate_width, plate_height, 1.6], center=true);

		// Electronics box
		color(black) translate([0,0,-2-(31.8/2)]) cube([50,50,31.8], center=true);
	} else {
		// The cutouts for the joystick
		// Mount place profile
		translate([0,0,-2/2]) cube([plate_width+5, plate_height+5, 2], center=true);
		// Hole for the joystick box
		translate([0,0,-(32/2 + 2)]) cube([55,55,32+1], center=true);

		// Round hole for joystick shaft
		translate([0,0,-2/2]) cylinder(r=10, h=10);
	}
}

module button_pad(color=red, undermount=4, cutout=false) {
	translate([0,-14,0]) button(color, cutout=cutout); // 1st bottom
	translate([7,-14+38.5,0]) button(color, cutout=cutout); // 1st top
	translate([33,   0,      0]) button(color, cutout=cutout); // 2nd bottom
	translate([33+7, 0+38.5, 0]) button(color, cutout=cutout); // 2nd top
	translate([33+36,     -6,      0]) button(color, cutout=cutout); // 3nd bottom
	translate([33+36+6.5, -6+38.5, 0]) button(color, cutout=cutout); // 3nd top
	translate([33+36+34,     -6-15,      0]) button(color, cutout=cutout); // 4th bottom
	translate([33+36+34+6.5, -6-15+38.5, 0]) button(color, cutout=cutout); // 4th top
	translate([-59,0,-undermount]) joystick(color, cutout=cutout);
}

button_pad();

