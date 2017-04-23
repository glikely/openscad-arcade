include <materials.scad>
use <control_panel.scad>

module mirror_dup()
{
	children();
	mirror([1,0,0]) children();
}

module panel_box(angle=4, size=[900,400,100], inset=[602,150], r=1000)
{
	curve_angle = asin((size[0]/2 - 275)/r);
	player_config = [[-curve_angle*1.5],
	                 [-curve_angle*0.5],
	                 [ curve_angle*0.5],
	                 [ curve_angle*1.5]];


	// Place the control panel. Angle is used to tilt it forward slightly
	rotate([angle,0,0]) panel(size=size, inset=inset, r=r);

	// Skirting
	color(BlackPaint) difference() {
		translate([0,0,-size[2]]) {
			translate([-inset[0]/2,-mdf_thick*1.5,0])
				cube([inset[0], mdf_thick, size[2]]);
			mirror_dup() {
				// Inset walls
				translate([-inset[0]/2,-inset[1]-(mdf_thick*1.5),0])
					cube([mdf_thick, inset[1], size[2]]);
				// Back side walls
				translate([-(size[0]-mdf_thick)/2,-inset[1]-(mdf_thick*1.5),0])
					cube([(size[0]-inset[0])/2,mdf_thick,size[2]]);
				// Side walls
				translate([-(size[0]-mdf_thick)/2,-size[1]/1.9,0])
					cube([mdf_thick, size[1]/1.9-inset[1]-mdf_thick, size[2]]);

			}
			// Box skirting
			translate([0,r-size[1]+100,0]) {
				for (p=player_config)
					rotate([0,0,p[0]]) translate([0,-r-75,0])
						translate([-135,0,0])
							cube([270, mdf_thick, size[2]]);
			}
		}
		rotate([angle,0,0])
			translate([-size[0]/2-0.1,-size[1]-0.1,-mdf_thick-plex_thick])
				cube([size[0]+0.2, size[1]+0.2, 1000]);
	}
}

panel_box();

