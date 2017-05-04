/**
 * cutlines() - Take a horizontal slice of the panel and create an outline model
 *              of the cut lines.
 * line_width: Width of cut lines to draw.
 */
module _cutlines(line_width)
{
	difference() {
		offset(delta=line_width) children();
		children();
	}
}
module cutlines(line_width=0.5) {
	linear_extrude(0.01, convexity=10)
		_cutlines(line_width) projection(cut=true) children();
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

/**
 * mirror_dup() - Place children twice, applying mirror() to one copy
 * v: vector of mirror plane
 *
 * Place two copies of children(). One unmodified, and one after applying the
 * mirror() modifier.
 */
module mirror_dup(v)
{
	children();
	mirror(v)
		children();
}

/**
 * fourcorners() - Utility for mirroring all children across the x & y planes
 *
 * Places 4 copies of children, mirrored across the x and y axies.
 */
module fourcorners()
{
	mirror_dup([0,1])
		mirror_dup([1,0])
			children();
}
