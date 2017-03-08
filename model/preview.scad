use <shape.scad>
use <top_cutout.scad>
use <bottom_cutout.scad>
use <switch_cutout.scad>

preview();
/* preview_tilted(); */
module preview() {
    /* color([70, 50, 15]/255) */
    translate(-[xmin(), ymin()])
    difference() {
        /* case(plate_width=plate_width-7); */
        shape();

        translate(front_height()*z()) rotate(tilt()*x())
        translate(0.1*z()) // hack to viewed properly
        mirror(z()) linear_extrude(height=lip_depth()+0.1)
        top_cutout_2D();

        translate(front_height()*z()) rotate(tilt()*x())
        translate(-(lip_depth()-0.1)*z())
        mirror(z()) linear_extrude(height=3.6+0.2)
        switch_cutout_2D();

        translate(front_height()*z()) rotate(tilt()*x())
        translate(-(lip_depth()+3.6)*z())
        mirror(z()) linear_extrude(height=tilted_height()-lip_depth()-3.6)
        bottom_cutout_2D();

        /* translate(front_height*z) rotate(plate_tilt*x) */
        /* translate(-(top_cutout_depth)*z) */
        /* linear_extrude(height=top_cutout_depth+1) */
        /* top_cutout2(); */

        /* translate(front_height*z) rotate(plate_tilt*x) */
        /* translate(-(3.6+lip_depth)*z) mirror(z) */
        /* linear_extrude(height=40) */
        /* rounding(d=1, $fn=12) */
        /* bottom_cutout(); */

        /* translate(front_height*z) rotate(plate_tilt*x) */
        /* translate(-(top_cutout_depth+4.1)*z) */
        /* linear_extrude(height=top_cutout_depth+1) */
        /* top_cutout3(); */

        /* translate(front_height*z) rotate(plate_tilt*x) */
        /* translate(-(top_cutout_depth)*z) */
        /* linear_extrude(height=top_cutout_depth+1) */
        /* top_drill(); */
    }
    /* color("green") */
    /* translate(front_height*z) */
    /* rotate(plate_tilt*x) */
    /* translate(-(3.6+lip_depth)*z) */
    /* mirror(z) */
    /* pcb(); */

    /* color("silver") */
    /* translate(front_height*z) */
    /* rotate(plate_tilt*x) */
    /* translate(-(top_cutout_depth-1.65-5)*z) */
    /* plate(); */

    /* translate(front_height*z) */
    /* rotate(plate_tilt*x) */
    /* translate(-(lip_depth-6.6)*z) */
    /* color([255, 255, 204]/255) */
    /* keycaps(); */

    /* translate([-19, -15, 0]) */
    /* % wood_block(); */
}

module preview_tilted()
{
    translate((tilted_height()-front_height())*z())
    rotate(-tilt()*x())
    preview();
}
