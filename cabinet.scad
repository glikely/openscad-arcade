include <materials.scad>
use <control_box.scad>

cabinet_height = 1760;
cabinet_depth = 690;
cabinet_width = 602 + mdf_thick * 2;

// The height and thickness of the control box
control_height = 40*25.8;
control_thick = 100;
control_inset = 200;

top_length = 500;
top_angle = 15;
marquee_angle = 70;
marquee_height = 186;

back_height = cabinet_height - sin(top_angle)*top_length - mdf_thick;

screen_height = 440;
bulkhead_height = 150;

module cabinet_side()
{
	color(BlackPaint) difference() {
		cube([cabinet_depth, cabinet_height, mdf_thick]);
		translate([500,cabinet_height+0.1,-0.1]) rotate([0,0,90+top_angle]) cube([1000,1000,mdf_thick+0.2]);
		translate([500,cabinet_height+0.1,-0.1]) rotate([0,0,-marquee_angle]) cube([1000,1000,mdf_thick+0.2]);
		translate([cabinet_depth+0.1,control_height-2*25.8,-0.1])
			rotate([0,0,65]) cube([500,150,mdf_thick+0.2]);
	}
}

module cabinet_panel(length, thickness=mdf_thick, color=BlackPaint)
{
	/* Cabinet panels get centred on the X axis */
	translate([-cabinet_width/2+mdf_thick, 0, 0]) color(color)
		cube([cabinet_width - mdf_thick*2, length, thickness]);
}

module cabinet()
{
	// Side Panels
	translate([-cabinet_width/2+mdf_thick,0,0]) rotate([90,0,-90]) cabinet_side();
	mirror([1,0,0]) translate([-cabinet_width/2+mdf_thick,0,0])
		rotate([90,0,-90]) cabinet_side();
	// Front Panel
	translate([0, -cabinet_depth+mdf_thick*1.5, 0])
		rotate([90,0,0]) cabinet_panel(control_height - control_thick);
	// Back Panel
	translate([0, -mdf_thick*0.5, 0])
		rotate([90,0,0]) cabinet_panel(back_height);
	// Bottom Panel
	translate([0, -cabinet_depth+mdf_thick*1.5, mdf_thick*0.5])
		cabinet_panel(cabinet_depth - mdf_thick*3);
	// Top Panel
	translate([0, -cabinet_depth * .72, cabinet_height+0.1])
		rotate([-top_angle,0,0]) translate([0,0,-mdf_thick*1.5])
			cabinet_panel(top_length);

	// Marquee
	translate([0, -cabinet_depth * .72, cabinet_height+0.1])
		rotate([-180+marquee_angle,0,0]) translate([0,mdf_thick,0]) {
			cabinet_panel(marquee_height, color=[1,1,0,0.4], thickness=2);
			// Speaker Panel
			translate([0, marquee_height, 2])
				rotate([180-marquee_angle-30,0,0])
					cabinet_panel(350);
		}

	// Control Bulkhead
	translate([0, -cabinet_depth+control_inset, control_height])
		rotate([115,0,0]) {
			cabinet_panel(bulkhead_height);
			// Screen Cover
			translate([0,bulkhead_height,0])rotate([-80,0,0])
				cabinet_panel(screen_height, color=[0,1,1,0.4], thickness=2);
		}


}

translate([0,cabinet_depth/2,0]) {
	cabinet();
	translate([0,-cabinet_depth+control_inset,control_height]) panel_box();
}
