use <list-comprehension-demos/sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/morphology.scad>
include <params.scad>

inch = 25.4;
unit = 19.05;

lead_margin = 2;
top_cutout_depth = 7     /*lip*/    +
                   5     /*switch*/ +
                   1.65  /*pcb*/    +
                   lead_margin;
front_height= 17;
tilt_angle=10;
round = 8;
margin=3;

screw_holes = [
    [0.14*inch, 1.51*inch],
    [11.1*inch, 1.51*inch],
    [1.005*inch, 2.635*inch],
    [5.06*inch, 1.87*inch],
    [7.51*inch, 0.38*inch],
    [10.249*inch, 2.636*inch],
];

x = [1, 0, 0];
y = [0, 1, 0];
z = [0, 0, 1];

/* plate_width = plate_width - 10; */

function sq(x) = pow(x, 2);

module case(
        plate_width=plate_width,
        plate_length=plate_length,
        tilt_angle=tilt_angle,
        front_height=front_height,
        margin=margin,
        round=round)
{
    R = 400;
    h1 = front_height;
    h2 = h1 + plate_width*sin(tilt_angle);
    w = plate_width*cos(tilt_angle);
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

    function t1(x) = b - sqrt(sq(R) - sq(x-a))-round;
    function t0(x) =
        /* let(b = margin) let(a = d1(0) / (2*(0-b))) let(c = t1(0) - a*sq(0-b)) */
        /* a*sq(x-b)+c; */
        let(b = margin)
        let(a = d1(0) / (o0*pow(-b, o0-1)))
        let(c = t1(0) - a*pow(-b, o0))
        a*pow(x-b, o0)+c;
    function t2(x) = 
        let(b = w+margin)
        let(a = d1(w) / (o2*pow(w-b, o2-1)))
        let(c = t1(w) - a*pow(w-b, o2))
        a*pow(x-b, o2)+c;
    function d1(x) = (x-a) / sqrt(sq(R) - sq(x-a));
    function d0(x) = 
        let(b = margin)
        let(a = d1(0) / (o0*pow(-b, o0-1)))
        let(c = t1(0) - a*pow(-b, o0))
        o0*a*pow(x-b, o0-1);
    function d2(x) = 
        let(b = w+margin)
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
            translation([0, i, traj(i)-round*2+0.1])
            * rotation(-90*x)
            * scaling([1, 2, 1])
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
    translate(-margin*x) side();
    rotate(90*y) translate(-margin*z)
        linear_extrude(height=plate_length+2*margin) proj();
    translate((plate_length+margin)*x) side();
}

module top_cutout1()
{
    translate(plate_width*y)
    /* outset(d=0.2, $fn=10) */
    polygon(plate_coords);
}

module top_cutout2()
{
    r = 5;
    difference()
    {
        top_cutout1();
        for (i = [0 : 1 : len(screw_holes)-1]) {
            translate(screw_holes[i]) {
                if (i == 0) translate([-r, -r]) square([r, 2*r]);
                if (i == 1) translate([ 0, -r]) square([r, 2*r]);
                circle(r=r);
            }
        }
    }
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
    polygon([[0, 0], [plate_length, 0],
            [plate_length, plate_width], [0, plate_width]]);
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
    module R3U400() { import("./keycaps/SA_R3U400.stl"); }
    module R4U100() { import("./keycaps/SA_R4U100.stl"); }
    module R4U150() { import("./keycaps/SA_R4U150.stl"); }

    translate(plate_width*y)
    for (sw = switch_info) {
        pos = sw[0];
        rot = sw[1];
        unit = sw[2];
        row = sw[3];
        translate(pos) rotate(rot)
        if (row == 0) {
            if (unit == 1)        R1U100();
        } else if (row == 1) {
            if (unit == 1)        R2U100();
            else if (unit == 1.5) R2U150();
        } else if (row == 2) {
            if (unit == 1)        R3U100();
            else if (unit == 1.5) R3U150();
        } else if (row == 3) {
            if (unit == 1)        R4U100();
            else if (unit == 1.5) R4U150();
        } else if (row == 4) {
            if (unit == 1)        R3U100();
            else if (unit == 1.5) R3U150();
            else if (unit == 4)   R3U400();
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
        case();

        translate(front_height*z) rotate(tilt_angle*x)
        translate(-(top_cutout_depth-lead_margin)*z)
        linear_extrude(height=top_cutout_depth+1)
        top_cutout1();

        translate(front_height*z) rotate(tilt_angle*x)
        translate(-(top_cutout_depth)*z)
        linear_extrude(height=top_cutout_depth+1)
        top_cutout2();

        translate(front_height*z) rotate(tilt_angle*x)
        translate(-(top_cutout_depth)*z)
        linear_extrude(height=top_cutout_depth+1)
        top_drill();
    }
    %translate(front_height*z)
    rotate(tilt_angle*x)
    translate(-(1.65+top_cutout_depth+5)*z)
    linear_extrude(height=1.65)
    pcb();

    translate(front_height*z)
    rotate(tilt_angle*x)
    translate(-5*z)
    color([255, 255, 204]/255)
    keycaps();

    translate([-15, -15, 0])
    % wood_block();
}


/* rotate(-10*x) */
intersection()
{
    translate([0, 15, 0])
    preview();
    /* cube([60, 150, 50]); */
}

/* translate([55, 0, 0]) */
/* %cube([10, 10, 5]); */
/* top_cutout2(); */

/* switch_cutout(); */


/* bottom_cutout(); */
/* top_cutout(); */
