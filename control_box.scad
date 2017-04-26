include <materials.scad>
use <control_panel.scad>

module mirror_dup()
{
	children();
	mirror([1,0,0]) children();
}

module panel_box(angle, size, inset, r, pc)
{
	curve_origin = r-size[1];
	front_edge = r ? sqrt(pow(r,2) - pow(size[0]/2,2))-curve_origin : size[1];
	back_edge = inset ? inset[1] : 0;
	side_angle = r ? asin((size[0]/2)/r) : 0;
	inset_radius = side_angle ? (curve_origin+back_edge)/cos(side_angle) : 0;
	back_width = side_angle ? 2*(curve_origin+back_edge)*sin(side_angle) : size[0];

	// Place the control panel. Angle is used to tilt it forward slightly
	rotate([angle,0,0]) panel(size=size, inset=inset, r=r, pc=pc);

	// Skirting
	color(BlackPaint) difference() {
		translate([0,0,-size[2]]) {
			// Back wall
			if (inset)
				translate([-inset[0]/2,-mdf_thick*1.5,0])
					cube([inset[0], mdf_thick, size[2]]);
			else
				translate([-back_width/2+mdf_thick*0.5,-mdf_thick*1.5,0])
					cube([back_width-mdf_thick*1, mdf_thick, size[2]]);
			mirror_dup() {
				if (inset) {
					// Inset walls
					translate([-inset[0]/2,-inset[1]-(mdf_thick*1.5),0])
						cube([mdf_thick, inset[1], size[2]]);
					// Back side walls
					translate([-(back_width-mdf_thick)/2,-inset[1]-(mdf_thick*1.5),0])
						cube([(back_width-inset[0])/2,mdf_thick,size[2]]);
				}
				// Side walls
				if (r) translate([10, curve_origin, 0])
					rotate([0,0,-side_angle])
						translate([0, mdf_thick/2-r, 0])
							cube([mdf_thick, r-inset_radius-mdf_thick, size[2]]);
				else translate([-(size[0]-mdf_thick)/2,-front_edge+mdf_thick/2,0])
					cube([mdf_thick, front_edge-back_edge-mdf_thick, size[2]]);
			}
			// Front Edge
			translate([-size[0]/2+mdf_thick*1.5,-front_edge+mdf_thick/2,0])
				cube([size[0]-mdf_thick*3, mdf_thick, size[2]]);
		}
		// Trim the box for the angle of the control panel.
		rotate([angle,0,0])
			translate([-size[0]/2-0.1,-size[1]-0.1,-mdf_thick-plex_thick])
				cube([size[0]+0.2, size[1]+0.2, 1000]);
	}
}

pconfig = [[6, "red", "sega2"],[6, "blue", "sega2"]];
//panel_box(angle=4, size=[900,400,100],inset=[602,150]);
translate([-300,0])
	panel_box(angle=4, size=[500,350,100], inset=[300,150], pc=pconfig);
translate([+300,0])
	panel_box(angle=4, size=[500,350,100], pc=pconfig);
translate([-300,500])
	panel_box(angle=4, size=[500,350,100], inset=[300,150], r=1000, pc=pconfig);
translate([+300,500])
	panel_box(angle=4, size=[500,350,100], r=1000,  pc=pconfig);

