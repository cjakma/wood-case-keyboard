use <list-comprehension-demos/sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/morphology.scad>
include <params.scad>

inch = 25.4;
unit = 19.05;

lead_margin = 2;
lip_depth = 9.5;
top_cutout_depth = lip_depth        +
                   5     /*switch*/ +
                   1.65  /*pcb*/    +
                   lead_margin;
front_height= 19.5;
case_tilt=10;
plate_tilt=9.5;
round = 6;
margin=[9, 3];

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


module case(
        plate_width=plate_width,
        plate_length=plate_length,
        case_tilt=case_tilt,
        front_height=front_height,
        margin=margin,
        round=round)
{
    R = 400;
    h1 = front_height;
    h2 = h1 + plate_width*sin(case_tilt);
    w = plate_width*cos(case_tilt);
    echo("h1", h1); 
    echo("h2", h2); 
    
    p = sq(h2-h1)/sq(w);
    q = (sq(w)+sq(h2)-sq(h1))/(2*(h2-h1));
    r = p+1;
    s = -2*(p*q+h1);
    t = p*sq(q)+sq(h1)-sq(R);
    b = (-s+sqrt(sq(s)-4*r*t))/(2*r);
    a = -sqrt(sq(R)-sq(h1-b));

    o0 = 5;
    o2 = 4;

    m1 = margin[1];
    m2 = margin[0];

    function sq(x) = pow(x, 2);
    function t1(x) = b - sqrt(sq(R) - sq(x-a))-round;
    function t0(x) =
        /* let(b = margin) let(a = d1(0) / (2*(0-b))) let(c = t1(0) - a*sq(0-b)) */
        /* a*sq(x-b)+c; */
        let(b = m1)
        let(a = d1(0) / (o0*pow(-b, o0-1)))
        let(c = t1(0) - a*pow(-b, o0))
        a*pow(x-b, o0)+c;
    function t2(x) = 
        let(b = w+m1)
        let(a = d1(w) / (o2*pow(w-b, o2-1)))
        let(c = t1(w) - a*pow(w-b, o2))
        a*pow(x-b, o2)+c;
    function d1(x) = (x-a) / sqrt(sq(R) - sq(x-a));
    function d0(x) = 
        let(b = m1)
        let(a = d1(0) / (o0*pow(-b, o0-1)))
        let(c = t1(0) - a*pow(-b, o0))
        o0*a*pow(x-b, o0-1);
    function d2(x) = 
        let(b = w+m1)
        let(a = d1(w) / (o2*pow(w-b, o2-1)))
        let(c = t1(w) - a*pow(w-b, o2))
        o2*a*pow(x-b,o2-1);
    function traj(x) =
        x <= 0 ? t0(x) :
        x <= w ? t1(x) : t2(x);
    function devi(x) = 
        x <= 0 ? d0(x) :
        x <= w ? d1(x) : d2(x);
    half_circle = [for (i = [0 : 180/20 : 180]) [cos(i), sin(i)]];

    module side() {
        function shape(r) = [for (xy = half_circle) [xy[0]*r, xy[1]*r]];
        interval= concat(
                [for (i=[-30:40/80:10]) i],
                [for (i=[10:(plate_width-20)/60:plate_width-10]) i],
                [for (i=[plate_width-10:40/80:plate_width+30]) i]);
        transform1 = [for (i = interval)
            translation([0, i, traj(i)])
            * rotation((-90+atan(devi(i)))*x)
            * rotation(180*z)
        ];
        transform2 = [for (i = interval)
            translation([0, i, traj(i)-round*3])
            * rotation(-90*x)
            * scaling([1, 3, 1])
        ];
        intersection() {
            union() {
                sweep(shape(round), transform1);
                sweep(square(round*2), transform2);
            }
            translate([-round*2, -50]) cube([4*round, w+100, 50]);
        }
    }
    module proj() {
        projection() rotate(-90*y) side();
    }
    translate(-m2*x) side();
    rotate(90*y) translate(-m2*z)
        linear_extrude(height=plate_length+2*m2) proj();
    translate((plate_length+m2)*x) side();
}

module top_cutout1()
{
    translate(plate_width*y) outset(d=0.3, $fn=10) polygon(plate_coords);
}

module top_cutout2()
{
    rounding(r=3.5, $fn=20)
    difference() {
        translate(plate_width*y) inset(r=2, $fn=10) polygon(plate_coords);
        for (i = [0 : 1 : len(screw_holes)-1]) translate(screw_holes[i]) circle(r=5);
    }
}

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
    outset(d=1, $fn=10)
    polygon([[0, 0], [plate_length, 0],
            [plate_length, plate_width], [0, plate_width]]);
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

module wood_block()
{
    cube([330, 130, 36]);
}

module preview() {
    color([70, 50, 15]/255)
    difference() {
        translate(3*y)
        case(plate_width=plate_width-7);

        translate(front_height*z) rotate(plate_tilt*x)
        translate(-(top_cutout_depth-lead_margin)*z)
        linear_extrude(height=top_cutout_depth+1)
        rounding(d=1, $fn=12)
        top_cutout1();

        translate(front_height*z) rotate(plate_tilt*x)
        translate(-(top_cutout_depth)*z)
        linear_extrude(height=top_cutout_depth+1)
        top_cutout2();

        translate(front_height*z) rotate(plate_tilt*x)
        translate(-(top_cutout_depth+4.1)*z)
        linear_extrude(height=top_cutout_depth+1)
        top_cutout3();

        translate(front_height*z) rotate(plate_tilt*x)
        translate(-(top_cutout_depth)*z)
        linear_extrude(height=top_cutout_depth+1)
        top_drill();
    }
    %color("green")
    translate(front_height*z)
    rotate(plate_tilt*x)
    translate(-(top_cutout_depth-1.65)*z)
    pcb();

    color("silver")
    translate(front_height*z)
    rotate(plate_tilt*x)
    translate(-(top_cutout_depth-1.65-5)*z)
    plate();

    translate(front_height*z)
    rotate(plate_tilt*x)
    translate(-(lip_depth-6.6)*z)
    color([255, 255, 204]/255)
    keycaps();

    /* translate([-19, -15, 0]) */
    /* % wood_block(); */
}


/* rotate(-plate_tilt*x) */
intersection()
{
    /* translate([0, 15, 0]) preview(); */
    /* translate(20*x) cube([60, 150, 50]); */
}

/* top_cutout3(); */
top_cutout2();
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
