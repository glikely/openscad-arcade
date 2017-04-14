screw_diameter = 23.8;
screw_length = 31.2;

button_diameter = 23.8;
button_height = 12.6;

switch_length = 6;
switch_width = 24;
switch_height = 18;

black = [0,0,0];
silver = [0.8,0.8,0.8];
red = [1,0,0];
green = [0,1,0];
blue = [0.1,0.1,1];
yellow = [1,1,0];

undermount_depth = 3;

module button(color = red) {
	color(color) {
		translate([0,0,-screw_length]) cylinder(r=screw_diameter/2,h=screw_length);
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
}


module joystick(color=red) {
	shaft_len = 27.5+31.8+3.9;
	plate_width = 65;
	plate_height = 97;

	// Ball top
	color(color) {
		translate([0,0,27.5+(32/2)]) sphere(34/2);
	}
	// shaft
	color(silver) translate([0,0,-shaft_len+28]) cylinder(r=4, h=shaft_len);

	// Disc
	color(black) cylinder(r=18, h=1);

	// mounting plate
	color(silver) translate([0,0,-1.6/2]) cube([plate_width, plate_height, 1.6], center=true);

	// Electronics box
	color(black) translate([0,0,-1.6-(30/2)]) cube([50,50,31.8], center=true);
}

module button_pad(color=red, undermount=4) {
	translate([0,-14,0]) button(color); // 1st bottom
	translate([7,-14+38.5,0]) button(color); // 1st top
	translate([33,   0,      0]) button(color); // 2nd bottom
	translate([33+7, 0+38.5, 0]) button(color); // 2nd top
	translate([33+36,     -6,      0]) button(color); // 3nd bottom
	translate([33+36+6.5, -6+38.5, 0]) button(color); // 3nd top
	translate([33+36+34,     -6-15,      0]) button(color); // 4th bottom
	translate([33+36+34+6.5, -6-15+38.5, 0]) button(color); // 4th top
	translate([-59,0,-undermount]) joystick(color);
}



