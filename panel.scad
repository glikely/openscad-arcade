include <controls.scad>

cab_width = 602;
cab_depth = 150;

panel_width = 1000;
panel_depth = 400;
panel_height = 100;

mdf_thick = 25.4 * 3 / 4;

curve_radius = 500;
curve_angle = asin((panel_width/2 - 275)/curve_radius);

// Top panel
%translate([0,0,-mdf_thick]) {
	union() {
		translate([-cab_width/2,0,0])
			cube([cab_width, cab_depth, mdf_thick]);
		intersection() {
			translate([-panel_width/2,-panel_depth,0])
				cube([panel_width, panel_depth, mdf_thick]);
			translate([0,curve_radius-panel_depth+150,0])
				cylinder(r=curve_radius+150, h=mdf_thick);
		}
	}
}

// Skirting
translate([0,cab_depth - mdf_thick, -(panel_height/2 + mdf_thick)]) {
	cube([cab_width, mdf_thick, panel_height], center=true);
}

// Game Controls
translate([0,curve_radius-panel_depth+150,0]) {
	rotate([0,0,-curve_angle * 1.5]) translate([0,-curve_radius,0]) button_pad();
	rotate([0,0,-curve_angle * 0.5]) translate([0,-curve_radius,0]) button_pad(blue);
	rotate([0,0, curve_angle * 0.5]) translate([0,-curve_radius,0]) button_pad(green);
	rotate([0,0, curve_angle * 1.5]) translate([0,-curve_radius,0]) button_pad(yellow);
}

