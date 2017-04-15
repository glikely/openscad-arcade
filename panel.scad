include <materials.scad>
use <controls.scad>

cab_width = 602;
cab_depth = 150;

panel_width = 1000;
panel_depth = 550;
panel_height = 100;

curve_radius = 500;
curve_angle = asin((panel_width/2 - 275)/curve_radius);

// Top panel
module panel_profile(thickness) {
	difference() {
		intersection() {
			translate([-panel_width/2,-panel_depth,0])
				cube([panel_width, panel_depth, thickness]);
			translate([0,curve_radius-panel_depth+150,0])
				cylinder(r=curve_radius+150, h=thickness);
		}
		union() {
			translate([cab_width/2,-cab_depth,-1])
				cube([(panel_width - cab_width)/2+1, cab_depth+1, thickness+2]);
			translate([-(panel_width/2+1),-cab_depth+1,-1])
				cube([(panel_width - cab_width)/2+1, cab_depth+1, thickness+2]);
			translate([cab_width/2,-cab_depth,0]) cube([cab_width, cab_depth, thickness]);
		}
	}
}

module panel_controls(cutout=false)
{
	// Game Controls
	translate([0,curve_radius-panel_depth+150,0]) {
		rotate([0,0,-curve_angle * 1.5]) translate([0,-curve_radius,0])
			button_pad(undermount=plex_thick+0.1, cutout=cutout, count=4);
		rotate([0,0,-curve_angle * 0.5]) translate([0,-curve_radius,0])
			button_pad(blue, undermount=plex_thick+0.1, cutout=cutout, count=6);
		rotate([0,0, curve_angle * 0.5]) translate([0,-curve_radius,0])
			button_pad(green, undermount=plex_thick+0.1, cutout=cutout, count=6);
		rotate([0,0, curve_angle * 1.5]) translate([0,-curve_radius,0])
			button_pad(yellow, undermount=plex_thick+0.1, cutout=cutout, count=4);
	}
}

module panel() {
	// MDF base panel
	difference() {
		translate([0,0,-(plex_thick + 0.2 + mdf_thick)])
			color(Oak) panel_profile(mdf_thick);
		panel_controls(cutout=true);
	}
	// Plexiglass top panel
	difference() {
		translate([0,0,-plex_thick])
			color([0,0,1,.3]) panel_profile(plex_thick);
		panel_controls(cutout=true);
	}
	panel_controls();
}

module panel_box() {
	panel();

	// Skirting
	color(Oak) translate([0,0,-(panel_height/2 + mdf_thick + plex_thick)]) {
		translate([0,-mdf_thick,0])
			cube([cab_width, mdf_thick, panel_height], center=true);
		translate([-(cab_width-mdf_thick)/2,-(cab_depth/2+(mdf_thick*1.5)),0])
			cube([mdf_thick, cab_depth, panel_height], center=true);
	}
}

panel_box();

