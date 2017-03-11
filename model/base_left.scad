use <base.scad>

cut = 160;
margin = 1;
size = base_size();
function right_half_trans() = -size[0]*x();

module left_half() {
    cube([cut+margin, size[1], size[2]]);
}

module right_half() {
    translate([cut-margin, 0, 0]) cube([size[0]-(cut-margin), size[1], size[2]]);
}

intersection() {
    left_half();
    translate(-[xmin(), ymin()]) base();
}

