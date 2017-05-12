use <controls.scad>

projection(cut=true) {
	translate([-36,0,1]) difference() {
		joystick(action="remove");
		translate([0,0,3]) joystick(action="remove");
	}

	translate([36,0,1]) difference() {
		joystick(action="remove");
		translate([0,0,-3]) joystick(action="remove");
	}
}

