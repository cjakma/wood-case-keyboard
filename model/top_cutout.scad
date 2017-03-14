include <params.scad>
use <base.scad>
use <scad-utils/morphology.scad>
use <plate.scad>

// maximum distance from top of your keyboard to switch mount surface.
lip_depth = 7.5;

// margin between case and switches
margin = 0.5;

top_cutout();
module top_cutout_2D()
{
    translate(plate_size()[1]*y())
    outset(r=margin, $fn=10)
    for (sw = switch_info) {
        pos = sw[0];
        rot = sw[1];
        u = sw[2];
        translate(pos) rotate(rot) square([u, 1]*unit(), true);
    }
}

module top_cutout()
{
    difference()
    {
        translate(-[1, 1]*margin)
        cube([plate_size()[0]+2*margin, plate_size()[1]+2*margin, block_height()+4]);
        translate((block_height()-lip_depth)*z())
        linear_extrude(height=lip_depth+4+0.1)
        top_cutout_2D();

        /* translate((block_height()-lip_depth()-5-0.5)*z()) */
        /* linear_extrude(height=lip_depth()+5+0.1+0.5+4) */
        /* plate_2D(); */
    }
}

function tilted_height() =
    front_height() + (ymax()-ymin())*sin(tilt());

function lip_depth() = lip_depth;

echo("tilted_height:", tilted_height());


