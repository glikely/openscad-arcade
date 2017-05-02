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

