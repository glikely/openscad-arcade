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
			color(BlackPaint)
				cube([switch_length, switch_width, switch_height], center = true);
	} else union() {
		// Dimensions for mounting hole. Right through all the layers
		translate([0,0,-(screw_length+10)]) {
			cylinder(r=28/2, h=screw_length+10+button_height);
			cylinder(r=40/2, h=20); // contersink for nuts
		}
	}
}

module joystick(color=red, undermount=0, cutout=false) {
	shaft_len = 27.5+31.8+3.9;
	plate_width = 65;
	plate_height = 97;

	if (!cutout) {
		translate([0,0,-undermount]) {
			// Ball top
			color(color) {
				translate([0,0,27.5+(32/2)]) sphere(34/2);
			}
			// shaft
			color(silver) translate([0,0,-shaft_len+28]) cylinder(r=4, h=shaft_len);

			// mounting plate
			color(silver) translate([0,0,-2/2]) cube([plate_width, plate_height, 1.6], center=true);

			// Electronics box
			color(BlackPaint) translate([0,0,-2-(31.8/2)]) cube([50,50,31.8], center=true);
		}
		// Dust Cover Disc
		color(black) cylinder(r=18, h=0.5);

	} else translate([0,0,-undermount]) {
		// The cutouts for the joystick
		// Mount place profile
		translate([0,0,-2/2]) cube([plate_width+5, plate_height+5, 2], center=true);
		// Hole for the joystick box
		translate([0,0,-(32/2 + 2)]) cube([55,55,32+1], center=true);

		// Round hole for joystick shaft
		translate([0,0,-2/2]) cylinder(r=10, h=10);
	}
}

module button_pad(color=red, undermount=0, cutout=false, count=8) {
	layout = [[0,-14,0],   [7,-14+38.5,0],
	          [33,0,0],    [33+7,38.5,0],
	          [33+36,-6,0],[33+36+6.5,-6+38.5],
	          [33+36+34,-6-15,0],[33+36+34+6.5,-6-15+38.5,0]];
	for(p=[0:count-1])
		translate(layout[p]) button(color, cutout=cutout); // 1st bottom
	translate([-59,0,0]) joystick(color, undermount=undermount, cutout=cutout);
}

module utrak_trackball(undermount=17, cutout=false)
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

	if (!cutout) translate([0,0,-undermount]){
		// Housing
		color(BlackPaint) difference() {
			translate([0,0,-box_height/2]) intersection() {
				cube([box_width,box_width,box_height], center=true);
				rotate([0,0,45])
					cube([diag_width,diag_length,box_height+0.2], center=true);
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
	} else translate([0,0,-undermount-box_height/2]) {
		intersection() {
			cube([box_width+5,box_width+5,box_height], center=true);
			rotate([0,0,45])
				cube([diag_width+5,diag_length+5,box_height+0.2], center=true);
		}
		cylinder(r=housing_radius, h=box_height + undermount);
	}
}

translate([0,200,0]) button_pad();
translate([200,200,0]) button_pad(cutout=true);
translate([0,0,0]) utrak_trackball();
translate([200,0,0]) utrak_trackball(cutout=true);
translate([0,-200,0]) utrak_trackball(undermount=19);
translate([200,-200,0]) utrak_trackball(undermount=19,cutout=true);

