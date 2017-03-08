include <params.scad>


// margin between pcb and case.
margin = 0.5;

module bottom_cutout_2D()
{
    outset(r=margin, $fn=5)
    square(plate_size);
}

module bottom_cutout()
{
    difference()
    {
        cube([plate_size()[0], plate_size()[1], block_height()]);

        translate((block_height()-lip_depth()-3.6)*z())
        linear_extrude(height=lip_depth()+3.6+0.1)
        switch_cutout_2D();
    }
}
