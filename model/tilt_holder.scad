use <base.scad>

module tilt_holder()
{
    difference()
    {
        cube([30, 130, 34]);
        rotate(tilt()*x()) cube([30, 200, 40]);
        cube([30, 40, 40]);

        rotate(tilt()*x()) translate([15, 60])  mirror(z()) screw_hole();
        rotate(tilt()*x()) translate([15, 90])  mirror(z()) screw_hole();
    }

    translate(130*y())
    difference()
    {
        cube([30, 25, 10]);
        translate([15, 15]) screw_hole();
    }

    module screw_hole()
    {
        translate(2*z()) {
            mirror(z()) translate(-0.1*z()) cylinder(d=3.1, h=20, $fn=20);
            cylinder(d1=3.1, d2=8, h=2.5, $fn=20);
            translate(2.5*z()) cylinder(d=8, h=20, $fn=20);
        }
    }
}

rotate(-y()*90)
tilt_holder();
