use <shape.scad>

translate(-80*x())
intersection() {
    {
        translate((160-1)*x()) cube([340-160+1, block_size()[1], block_size()[2]]);
        translate(-[xmin(), ymin()]) shape();
    }
}
