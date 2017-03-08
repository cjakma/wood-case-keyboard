include <params.scad>
use <shape.scad>
use <top_cutout.scad>

switch_cutout();
/* switch_cutout_2D(); */
module switch_cutout_2D()
{
    module mirrored(d) {
        children();
        mirror(d) children();
    }
    module stabil() {
        translate([-0.131, -0.26]*inch())
        square([0.262, 0.484]*inch());
    }
    module cutout(unit) {
        square(0.551*inch(), true);
        mirrored(x()) {
            if (2 <= unit && unit < 3)   {translate(-0.94/2*inch()*x()) stabil(); } 
            if (3 <= unit && unit < 4.5) {translate(-1.50/2*inch()*x()) stabil(); } 
            if (unit == 6)               {translate(43.5*x()) stabil(); }
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

module switch_cutout()
{
    difference()
    {
        cube([plate_size()[0], plate_size()[1], block_height()]);

        translate((block_height()-lip_depth()-3.6)*z())
        linear_extrude(height=lip_depth()+3.6+0.1)
        switch_cutout_2D();
    }
}
