use <list-comprehension-demos/sweep.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
include <common.scad>

render()
translate(-[xmin(), ymin()]) base();

module base()
{
    echo("size: ",[xmax()-xmin(), ymax()-ymin()]);
    echo("x: ", [xmin(), xmax()]);
    echo("y: ", [ymin(), ymax()]);
    echo(pow(2, 1/2));

    module side() {
        function shape(r) = [for (xy = half_circle) [xy[0]*r, xy[1]*r]];
        interval= concat(
                [for (i=[-10:20/30:10]) i],
                [for (i=[10:(py-20)/20:py-10]) i],
                [for (i=[py-10:20/20:py+10]) i]);
        transform1 = [for (i = interval)
            translation([0, i, traj(i)])
            * rotation((-90+atan(devi(i)))*x)
            * rotation(180*z)
        ];
        transform2 = [for (i = interval)
            translation([0, i, traj(i)-roundness*3])
            * rotation(-90*x)
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
        projection() rotate(-90*y) side();
    }

    translate(-mx*x) side();
    rotate(90*y) translate(-mx*z)
        linear_extrude(height=px+2*mx) proj();
    translate((px+mx)*x) side();
    %translate([xmin(), ymin()]) cube([xmax()-xmin(), ymax()-ymin(), 36]);
}
