/**
 * cutlines() - Take a horizontal slice of the panel and create an outline model
 *              of the cut lines.
 * line_width: Width of cut lines to draw.
 */
module cutlines(line_width=0.25)
{
	intersection() {
		minkowski() {
			difference() {
				cylinder(r=2000, h=0.09);
				children();
			}
			cylinder(r=line_width, h=0.01);
		}
		children();
	}
}

/**
 * round_corners() - Given a 2D shape, round off the corners to a given radius
 * r: radius of corner rounding.
 *
 * Rounds off the corners of a 2D shape by creating use of offsets. The
 * modifier first trims a depth of 'r' off all edges, then adds r*2 to get
 * rounding on the convex corners. Finally, it trims the edges again by 'r' to
 * round the concave corners.
 *
 * Note: any cutout or segment narrower than 2*r will disappear when this modifier
 * is appiled
 */
module round_corners(r)
{
	offset(r=-r) offset(r=r*2) offset(delta=-r) children();
}
