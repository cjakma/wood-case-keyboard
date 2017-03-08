use <shape.scad>

intersection() {
    translate(80*x())
    {
        translate((160-1)*x()) cube([340-160+1, block_size()[1], block_size()[2]]);
        translate(-[xmin(), ymin()]) shape();
    }
}
