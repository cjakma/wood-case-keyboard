use <shape.scad>

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
        translate(4*z()) {
            mirror(z()) cylinder(d=4, h=20);
            cylinder(d=6, h=20);
        }
    }
}

rotate(-y()*90)
tilt_holder();
