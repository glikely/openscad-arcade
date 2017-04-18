include <materials.scad>
use <control_panel.scad>

module mirror_dup()
{
	children();
	mirror([1,0,0]) children();
}

module panel_box(angle=4, width=1000, depth=550, height=100, cab_width=602,
                 inset=150, curve_radius=500)
{
	curve_angle = asin((width/2 - 275)/curve_radius);
	player_config = [[-curve_angle*1.5],
	                 [-curve_angle*0.5],
	                 [ curve_angle*0.5],
	                 [ curve_angle*1.5]];


	// Place the control panel. Angle is used to tilt it forward slightly
	rotate([angle,0,0]) panel();

	// Skirting
	color(BlackPaint) difference() {
		translate([0,0,-height]) {
			translate([-cab_width/2,-mdf_thick*1.5,0])
				cube([cab_width, mdf_thick, height]);
			mirror_dup() {
				// Inset walls
				translate([-cab_width/2,-inset-(mdf_thick*1.5),0])
					cube([mdf_thick, inset, height]);
				// Back side walls
				translate([-(width-mdf_thick)/2,-inset-(mdf_thick*1.5),0])
					cube([(width-cab_width)/2,mdf_thick,height]);
				// Side walls
				translate([-(width-mdf_thick)/2,-depth/1.9,0])
					cube([mdf_thick, depth/1.9-inset-mdf_thick, height]);

			}
			// Box skirting
			translate([0,curve_radius-depth+100,0]) {
				for (p=player_config)
					rotate([0,0,p[0]]) translate([0,-curve_radius-75,0])
						translate([-135,0,0])
							cube([270, mdf_thick, height]);
			}
		}
		rotate([angle,0,0])
			translate([-width/2-0.1,-depth-0.1,-mdf_thick-plex_thick])
				cube([width+0.2, depth+0.2, 1000]);
	}
}

panel_box();

