use <list-comprehension-demos/sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
include <params.scad>

// margin as 2D vector, to be added outside of the keyboard 
margin = [3, 2];

// tilt angle of the keyboard in degree unit
tilt = 10;

// ront_height height of the keyboard at front side. overall height will be
// calculated based on front_height and tilt_angle. make sure that there is
// enough room for PCB to be placed under the keyboard.
front_height = 14;

// roundnessness radius at side
roundness = 10;

// size of material to carve
block_size = [330, 130, 34];


module shape()
{
    echo("size: ",[xmax()-xmin(), ymax()-ymin()]);
    echo("x: ", [xmin(), xmax()]);
    echo("y: ", [ymin(), ymax()]);
    echo(pow(2, 1/2));

    module side() {
        function shape(r) = [for (xy = half_circle) [xy[0]*r, xy[1]*r]];
        interval= concat(
                [for (i=[-20:30/40:10]) i],
                [for (i=[10:(py-20)/20:py-10]) i],
                [for (i=[py-10:40/30:py+30]) i]);
        transform1 = [for (i = interval)
            translation([0, i, traj(i)])
            * rotation((-90+atan(devi(i)))*x())
            * rotation(180*z())
        ];
        transform2 = [for (i = interval)
            translation([0, i, traj(i)-roundness*3])
            * rotation(-90*x())
            * scaling([1, 3, 1])
        ];
        intersection() {
            union() {
                sweep(shape(roundness), transform1);
                sweep(square(roundness*2), transform2);
            }
            translate([-roundness*2, -50]) cube([4*roundness, w+100, 50]);
        }
    }
    module proj() {
        projection() rotate(-90*y()) side();
    }

    translate(-mx*x()) side();
    rotate(90*y()) translate(-mx*z())
        linear_extrude(height=px+2*mx) proj();
    translate((px+mx)*x()) side();
    %translate([xmin(), ymin()]) cube([xmax()-xmin(), ymax()-ymin(), 36]);
}
translate(-[xmin(), ymin()]) shape();


function inch() = 25.4;
function unit() = 19.05;
function x() = [1, 0, 0];
function y() = [0, 1, 0];
function z() = [0, 0, 1];

mx = margin[0];
my = margin[1];
px = plate_size[0];
py = plate_size[1];

R = 400;
h1 = front_height;
h2 = h1 + py*sin(tilt);
w = py*cos(tilt);

p = sq(h2-h1)/sq(w);
q = (sq(w)+sq(h2)-sq(h1))/(2*(h2-h1));
r = p+1;
s = -2*(p*q+h1);
t = p*sq(q)+sq(h1)-sq(R);
b = (-s+sqrt(sq(s)-4*r*t))/(2*r);
a = -sqrt(sq(R)-sq(h1-b));

o0 = 6;
o2 = 4;

function sq(x) = pow(x, 2);
function t1(x) = b - sqrt(sq(R) - sq(x-a))-roundness;
function t0(x) =
    let(b = my)
    let(a = d1(0) / (o0*pow(-b, o0-1)))
    let(c = t1(0) - a*pow(-b, o0))
    a*pow(x-b, o0)+c;
function t2(x) = 
    let(b = w+my)
    let(a = d1(w) / (o2*pow(w-b, o2-1)))
    let(c = t1(w) - a*pow(w-b, o2))
    a*pow(x-b, o2)+c;
function d1(x) = (x-a) / sqrt(sq(R) - sq(x-a));
function d0(x) = 
    let(b = my)
    let(a = d1(0) / (o0*pow(-b, o0-1)))
    let(c = t1(0) - a*pow(-b, o0))
    o0*a*pow(x-b, o0-1);
function d2(x) = 
    let(b = w+my)
    let(a = d1(w) / (o2*pow(w-b, o2-1)))
    let(c = t1(w) - a*pow(w-b, o2))
    o2*a*pow(x-b,o2-1);
function traj(x) =
    x <= 0 ? t0(x) :
    x <= w ? t1(x) : t2(x);
function devi(x) = 
    x <= 0 ? d0(x) :
    x <= w ? d1(x) : d2(x);
function ymin() = 
    let(b = my)
    let(a = d1(0) / (o0*pow(-b, o0-1)))
    let(c = t1(0) - a*pow(-b, o0))
    -abs(pow(-c/a, 1/o0))+b-roundness;
function ymax() =
    let(b = w+my)
    let(a = d1(w) / (o2*pow(w-b, o2-1)))
    let(c = t1(w) - a*pow(w-b, o2))
    abs(pow(-c/a, 1/o2))+b+roundness;
function xmin() = -mx-roundness;
function xmax() = px+mx+roundness;
function front_height() = front_height;
function tilt() = tilt;
function plate_size() = plate_size;
function block_height() = block_size[2];

half_circle = [for (i = [0 : 180/16 : 180]) [cos(i), sin(i)]];
