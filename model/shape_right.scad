use <shape.scad>

intersection() {
    translate(80*x())
    {
        cube([250, block_size()[1], block_size()[2]]);
        translate(-[xmin(), ymin()]) shape();
    }
}
