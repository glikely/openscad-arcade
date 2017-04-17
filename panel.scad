include <materials.scad>
use <controls.scad>

inset_width = 602;
inset_depth = 150;

panel_width = 1000;
panel_depth = 550;
panel_height = 100;
panel_angle = 4;

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
			translate([inset_width/2,-inset_depth,-1])
				cube([(panel_width - inset_width)/2+1, inset_depth+1, thickness+2]);
			translate([-(panel_width/2+1),-inset_depth+1,-1])
				cube([(panel_width - inset_width)/2+1, inset_depth+1, thickness+2]);
			translate([inset_width/2,-inset_depth,0]) cube([inset_width, inset_depth, thickness]);
		}
	}
}

player_config_1 = [[0, 8, red]];
player_config_2 = [[-curve_angle*0.5, 6, red],
                   [ curve_angle*0.5, 6, blue]];
player_config_3 = [[-curve_angle, 6, red],
                   [           0, 6, blue],
                   [ curve_angle, 6, yellow]];
player_config_4 = [[-curve_angle*1.5, 4, red],
                   [-curve_angle*0.5, 6, blue],
                   [ curve_angle*0.5, 6, green],
                   [ curve_angle*1.5, 4, yellow]];

module panel_controls(cutout=false, skirting=false, start_spacing=120, start_colour=[1,1,1],
                      player_config=player_config_4, coin_spacing=50, trackball=true)
{
	num_players = len(player_config);

	if (!skirting) {
		// Player Start buttons
		translate([-start_spacing*(num_players-1)/2, -75, 0])
			for (i=[0:num_players-1]) {
				translate([start_spacing*i-coin_spacing/2,0,0]) {
					button(color=start_colour, cutout=cutout);
					translate([0,-40,0]) text("start", halign="center");
				}
				if (coin_spacing > 0) {
					translate([start_spacing*i+coin_spacing/2,0,0]) {
						button(color=player_config[i][2], cutout=cutout);
						translate([0,-40,0]) text("coin", halign="center");
					}
				}
			}

		// Game Controls
		translate([0,curve_radius-panel_depth+100,0]) {
			for (p=player_config)
				rotate([0,0,p[0]]) translate([0,-curve_radius,0])
					button_pad(undermount=plex_thick+0.1, cutout=cutout,
						   count=p[1], color=p[2]);
		}

		if (trackball)
			translate([0,-panel_depth+300,0]) utrak_trackball(cutout=cutout);
	} else {
		// Box skirting

		translate([0,curve_radius-panel_depth+100,0]) {
			for (p=player_config)
				rotate([0,0,p[0]]) translate([0,-curve_radius-75,0])
					translate([-135,0,0])
						cube([270, mdf_thick, panel_height]);
		}
	}
}

module panel_twolayer()
{
	// MDF base panel
	translate([0,0,-(plex_thick + 0.2 + mdf_thick)])
		color(FiberBoard) panel_profile(mdf_thick);

	// Plexiglass top panel
	translate([0,0,-plex_thick])
		color([0,0,1,.3]) panel_profile(plex_thick);
}

module panel() {
	difference() {
		panel_twolayer();
		panel_controls(cutout=true);
	}
	panel_controls();
}

module mirror_dup()
{
	children();
	mirror([1,0,0]) children();
}

module panel_box() {
	rotate([panel_angle,0,0]) panel();

	// Skirting
	color(BlackPaint) difference() {
		translate([0,0,-panel_height]) {
			translate([-inset_width/2,-mdf_thick*1.5,0])
				cube([inset_width, mdf_thick, panel_height]);
			mirror_dup() {
				// Inset walls
				translate([-inset_width/2,-inset_depth-(mdf_thick*1.5),0])
					cube([mdf_thick, inset_depth, panel_height]);
				// Back side walls
				translate([-(panel_width-mdf_thick)/2,-inset_depth-(mdf_thick*1.5),0])
					cube([(panel_width-inset_width)/2,mdf_thick,panel_height]);
				// Side walls
				translate([-(panel_width-mdf_thick)/2,-panel_depth/1.9,0])
					cube([mdf_thick, panel_depth/1.9-inset_depth-mdf_thick, panel_height]);

			}
			// Front walls (curved with controls)
			panel_controls(skirting=true);
		}
		rotate([panel_angle,0,0])
			translate([-panel_width/2-0.1,-panel_depth-0.1,-mdf_thick-plex_thick])
				cube([panel_width+0.2, panel_depth+0.2, 1000]);
	}
}

panel_box();

