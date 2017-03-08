use <list-comprehension-demos/sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/morphology.scad>
include <params.scad>

inch = 25.4;
unit = 19.05;

lead_margin = 2;
lip_depth = 8;
top_cutout_depth = lip_depth        +
                   5     /*switch*/ +
                   1.65  /*pcb*/    +
                   lead_margin;
front_height= 13.5;
case_tilt=10;
plate_tilt=9.5;
round = 7;
margin=[3, 3];

screw_holes = [
    [0.2, 2.0],
    [14.8, 2.5],
    [1.375, 3.5],
    [6.75, 2.5],
    [9.5, 0.5],
    [13.625, 3.5]
]*unit;

x = [1, 0, 0];
y = [0, 1, 0];
z = [0, 0, 1];


/* plate_width = plate_width - 10; */


module top_cutout3()
{
    size = [11, 11];
    translate([unit, plate_width]) translate(-size+size[0]/2*x) square(size);
}

module top_drill()
{
    for (i = [0 : 1 : len(screw_holes)-1]) {
        translate(screw_holes[i]) circle(d=2.4, $fn=10);
    }
}

module bottom_cutout()
{
    top_cutout1();
    /* outset(d=1, $fn=10) */
    /* polygon([[0, 0], [plate_length, 0], */
            /* [plate_length, plate_width], [0, plate_width]]); */
}

module pcb()
{
    linear_extrude(height=1.65)
    translate(plate_width*y) polygon(plate_coords);
}

module plate()
{
    linear_extrude(height=1.5)
    difference()
    {
        /* polygon([[0, 0], [plate_length, 0], */
                /* [plate_length, plate_width], [0, plate_width]]); */
        translate(plate_width*y) polygon(plate_coords);
        switch_cutout();
    }
}

module switch_cutout()
{
    inch = 25.4;
    module mirrored(d) {
        children();
        mirror(d) children();
    }
    module stabil() {
        translate([-0.131*inch, -0.26*inch])
        square([0.262*inch, 0.484*inch]);
    }
    module cutout(unit) {
        square(0.551*inch, true);
        mirrored(x) {
            if (2 <= unit && unit < 3)   {translate(-0.94/2*inch*x) stabil(); } 
            if (3 <= unit && unit < 4.5) {translate(-1.50/2*inch*x) stabil(); } 
            if (unit == 6)               {translate(43.5*x) stabil(); }
        }
    }
    translate(plate_width*y)
    for (sw = switch_info) {
        pos = sw[0];
        rot = sw[1];
        unit = sw[2];
        row = sw[3];
        translate(pos) rotate(rot) cutout(unit);
    }
}

module wood_block()
{
    cube([330, 130, 36]);
}

module keycaps()
{
    module R1U100() { import("./keycaps/SA_R1U100.stl"); }
    module R2U100() { import("./keycaps/SA_R2U100.stl"); }
    module R2U150() { import("./keycaps/SA_R2U150.stl"); }
    module R3U100() { import("./keycaps/SA_R3U100.stl"); }
    module R3U150() { import("./keycaps/SA_R3U150.stl"); }
    module R3U175() { import("./keycaps/SA_R3U175.stl"); }
    module R3U225() { import("./keycaps/SA_R3U225.stl"); }
    module R3U400() { import("./keycaps/SA_R3U400.stl"); }
    module R3U600() { import("./keycaps/SA_R3U600.stl"); }
    module R4U100() { import("./keycaps/SA_R4U100.stl"); }
    module R4U150() { import("./keycaps/SA_R4U150.stl"); }
    module R4U175() { import("./keycaps/SA_R4U175.stl"); }
    module R4U225() { import("./keycaps/SA_R4U225.stl"); }

    translate(plate_width*y)
    for (sw = switch_info) {
        pos = sw[0];
        rot = sw[1];
        unit = sw[2];
        row = sw[3];
        translate(pos) rotate(rot)
        if (row == 0) {
            if (unit == 1)         R1U100();
        } else if (row == 1) {     
            if (unit == 1)         R2U100();
            else if (unit == 1.5)  R2U150();
        } else if (row == 2) {     
            if (unit == 1)         R3U100();
            else if (unit == 1.5)  R3U150();
            else if (unit == 1.75) R3U175();
            else if (unit == 2.25) R3U225();
        } else if (row == 3) {     
            if (unit == 1)         R4U100();
            else if (unit == 1.5)  R4U150();
            else if (unit == 1.75) R4U175();
            else if (unit == 2.25) R4U225();
        } else if (row == 4) {     
            if (unit == 1)         R3U100();
            else if (unit == 1.5)  R3U150();
            else if (unit == 4)    R3U400();
            else if (unit == 6)    R3U600();
            else if (unit == 6.25) R3U625();
        }
    }
}

module preview() {
    /* color([70, 50, 15]/255) */
    difference() {
        /* case(plate_width=plate_width-7); */
        case();

        translate(front_height*z) rotate(plate_tilt*x)
        translate(0.4*z) mirror(z)
        linear_extrude(height=lip_depth)
        rounding(d=1, $fn=12)
        top_cutout1();

        translate(front_height*z) rotate(plate_tilt*x)
        translate(-(top_cutout_depth)*z)
        linear_extrude(height=top_cutout_depth+1)
        top_cutout2();

        translate(front_height*z) rotate(plate_tilt*x)
        translate(-(3.6+lip_depth)*z) mirror(z)
        linear_extrude(height=40)
        rounding(d=1, $fn=12)
        bottom_cutout();

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


/* rotate(-plate_tilt*x) */
/* intersection() */
/* { */
    /* translate([0, 15, 0]) preview(); */
    /* translate(20*x) cube([60, 150, 50]); */
/* } */


module left_half()
{
    intersection() {
        translate([11, 14]) case();
        cube([200, 130, 36]);
    }
}

module right_half()
{
    translate([-80, 0, 0])
    intersection() {
        translate([11, 14]) case();
        translate([150, 0, 0]) cube([200, 130, 36]);
    }
}
/* right_half(); */

module front_clamp()
{
    difference() {
        cube([30, 30, 34]);
        translate([-150, 22, 21]) rotate(-plate_tilt*x) case();
        translate([15, 20]) {
            cylinder(d=5, h=30);
            translate(10*z) cylinder(d=10, h=50);
        }
    }
}

module back_clamp()
{
    difference() {
        cube([50, 30, 34]);
        translate([-150, -100, 21]) rotate(-plate_tilt*x) case();
        translate([25, 20]) {
            cylinder(d=5, h=30);
            translate(10*z) cylinder(d=10, h=50);
        }
    }
}
preview();

/* rotate(-90*y) back_clamp(); */
/* translate(40*x) rotate(-90*y) front_clamp(); */
/* translate(80*x) rotate(-90*y) front_clamp(); */

/* translate([11, 14]) case(); */
/* %wood_block(); */
/* translate([0, 15, 0]) preview(); */
/* top_cutout2(); */
/* top_cutout3(); */
/* top_cutout2(); */
/* switch_cutout(); */
/* switch_cutout(); */
/* color("red") top_drill(); */
/* %pcb(); */

/* translate([55, 0, 0]) */
/* %cube([10, 10, 5]); */
/* top_cutout2(); */

/* switch_cutout(); */


/* bottom_cutout(); */
/* top_cutout(); */
