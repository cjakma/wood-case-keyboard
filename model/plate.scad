include <params.scad>
use <base.scad>
use <top_cutout.scad>

difference()
{
    top_cutout_2D();
    plate_2D();
}

module plate_2D()
{
    module mirrored(d) {
        children();
        mirror(d) children();
    }
    module stabil() {
        translate([0, -0.03]*inch()) {
            square([0.13, 0.55]*inch(), true);
            mirrored(y()) translate((0.55*inch()-2)/2*y()) square([0.13*inch()+1, 2], true);
        }
    }
    module switch() {
        square(0.55*inch(), true);
        mirrored(x()) mirrored(y())
        translate(0.1972/2*inch()*y()) square([0.6140/2, (0.55-0.1972)/2]*inch());
    }
    module cutout(unit) {
        if (unit == 6)  translate(0.5*unit()*x()) switch();
        else            switch();
        mirrored(x()) {
            if (unit == 6)                    {translate(2.5*unit()*x())     stabil(); }
            else if (2 <= unit && unit < 3)   {translate(-0.94/2*inch()*x()) stabil(); } 
            else if (3 <= unit && unit < 4.5) {translate(-1.50/2*inch()*x()) stabil(); } 
            else if (4.5 <= unit && unit < 8) {translate(-5.25/2*inch()*x()) stabil(); } 
        }
    }
    translate(plate_size()[1]*y())
    for (sw = switch_info) {
        pos = sw[0];
        rot = sw[1];
        unit = sw[2];
        row = sw[3];
        translate(pos) rotate(rot) cutout(unit);
    }
}

