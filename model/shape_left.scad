use <shape.scad>

intersection() {
    cube([160+1, block_size()[1], block_size()[2]]);
    translate(-[xmin(), ymin()]) shape();
}

