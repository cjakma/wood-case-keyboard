include<common.scad>
use <base.scad>
use <top_cutout.scad>
use <bottom_cutout.scad>
use <plate.scad>

render()
preview();
/* preview_tilted(); */

module preview() {
    /* color([70, 50, 15]/255) */
    translate(-[xmin(), ymin()])
    difference() {
        /* case(plate_width=plate_width-7); */
        base();

        translate(front_height*z) rotate(tilt*x)
        translate(0.2*z) // hack to viewed properly
        mirror(z) linear_extrude(height=lip_depth+0.2)
        top_cutout_2D();

        translate(front_height*z) rotate(tilt*x)
        translate(-(lip_depth-0.1)*z)
        mirror(z) linear_extrude(height=3.6+0.2)
        plate_2D();

        translate(front_height*z) rotate(tilt*x)
        translate(-(lip_depth+3.6)*z)
        mirror(z) linear_extrude(height=tilted_height()-lip_depth-3.6)
        bottom_cutout_2D();
    }
}

module preview_tilted()
{
    translate((tilted_height()-front_height)*z)
    rotate(-tilt*x)
    preview();
}
