include <common.scad>

module back_holder()
{
    mirror(x) cube([20, 60, 16]);
    cube([20, 60, 4]);
    translate(20*x)
    difference()
    {
        cube([20, 60, 16]);
        translate([10, 15, 0]) screw_hole();
        translate([10, 45, 0]) screw_hole();
        translate([10, 30, -2]) {
            cylinder(d=3.1, h=20, $fn=12);
            cylinder(d=6.3, h=13, $fn=6);
        }
    }

    module screw_hole()
    {
        translate(2*z) {
            mirror(z) translate(-0.1*z) cylinder(d=3.1, h=20, $fn=20);
            cylinder(d1=3.1, d2=8, h=2.5, $fn=20);
            translate(2.5*z) cylinder(d=8, h=20, $fn=20);
        }
    }
}

module clip()
{
    difference()
    {
        cube([20, 20, 5]);
        translate([10, 10, -1]) hull()
        {
            $fn=24;
            translate(1.5*x) cylinder(d=3.2, h=7); 
            translate(-1.5*x) cylinder(d=3.2, h=7); 
        }
    }
    translate(20*x) rotate(-80*y)
    {
        cube([20, 20, 5]);
        translate(15*x) rotate(90*y) cube([15, 20, 5]);
    }
}

module print()
{
    rotate(90*x) back_holder();
    translate(30*y) rotate(90*x) back_holder();
    translate([50, 0, 0]) rotate(90*x) clip();
    translate([50, 30, 0]) rotate(90*x) clip();

}

module preview()
{
    translate(20*z)
       rotate(180*z) rotate((180-tilt())*x) base();
    translate(40*y)
        back_holder();

    translate([40, 80, 17])
    rotate(180*z)
    rotate(-10*y)
    clip();
}

print();
