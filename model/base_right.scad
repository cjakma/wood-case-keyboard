use <base.scad>
use <base_left.scad>

translate(right_half_trans())
intersection() {
    {
        right_half()
        translate((160-1)*x()) cube([block_size()[0]-(160-1), block_size()[1], block_size()[2]]);
        translate(-[xmin(), ymin()]) base();
    }
}
