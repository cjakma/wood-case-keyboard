![look1][look1]

# Brief
This is a hobby project, to make a copy of HHKB made of wood,
but not limited to it. It is fully customizable, parameterized
toolchain to generate a keyboard case.

## Features
- Made of wood
- Nice curved shape
- Customizable layout and shape
- Open bottom (minimizing overall height and show off your PCB!)
- Compatible with PCBs with SMD components(?)

## Caveats
- The bottom surface is not flat. I started with flat wood block, but some
  distortion is made at some point.
- Open bottom may not a good idea in a long term. And you always have to worry
  about conductive things around your desk.
- Layout support is quiet limited at this point. It can parse only subset of
  [keyboard-layout-editor](http://www.keyboard-layout-editor.com/)s syntax.
  Result maybe ugly with other layouts than 60% board.
<!-- - You have to make PCB yourself unless you like [HHKB layout](https://github.com/jinhwanlazy/hhkb-pcb).  -->

# Dependancies
- python3
- [python-shapely](https://pypi.python.org/pypi/Shapely)
- [Openscad](http://www.openscad.org/) - nightly version is recommended
- [OskarLinde/scad-utils](https://github.com/OskarLinde/scad-utils)
- [openscad/list-comprehension-demos](https://github.com/openscad/list-comprehension-demos)

# Build
Open `model/common.sacd` and modify parameters. You have to set `block_size`
properly even if you don't want to change anything. See
[Customization](#customization) section for details.

Following command will generate all 3D and 2D models you need, in
`stl` and `dxf` format, under `out` directory. After you excecute `make` 
successfuly, you can open `model/preview.scad` and see how it will look
like.

    git clone https://github.com/jinhwanlazy/wood-case-keyboard
    cd wood-case-keyboard
    make

In OSX, you might have to specify full path of openscad.

    make SCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD

# Customization
## Layout
Layout definitions are located under `layout` directory. They are 
compatible with <http://www.keyboard-layout-editor.com/>. 
You can feed them with following command.

    make clean
    make LAYOUT=layout/plank.layout

## Parameters
preparing...

# Instruction
I have used a [Shapeoko1](https://www.shapeoko.com/shapeoko1.html) for milling
, and [PyCam](http://pycam.sourceforge.net/) to generate 
gcodes. It was painfull job.
I have made mistakes(forgetting to change
bit, feeding wrong gcode), and encountered number of hardware problems(slipping
bits, burning wood, missing steps, etc). I had to make monkeypatchs everytime
something goes wrong. I highly recommend you to use commercial grade
toolchains or just talk with manufacturer.  I'll leave here very brief steps
I have made, rather than full instruction. 

0. I used 330 * 130 * 34mm walnut block.
1. Print `back_holder.stl` and `tilt_holder.stl` with a 3D printer.
2. Fix wood block on CNC mill, and carve it with `base.stl`. I had to split it
two pieces, due to limitaion of build space. 
![ins2][ins2]
3. Fix a pair of `tilt_holder` with screw at bottom of the wood block.
![ins3][ins3]
4. Place wood block again, and cut it with `top_cutout.dxf`.
Cut depth is `lip_depth`mm from the highest point of the woodblock. It is
defined in `common.scad`.
The size of the model is arbitrary. Ignore the contour.
You have to cutout only pockets of the model.
The origin of the model is set to bottom leftmost key corner.
![ins4][ins4]
5. Cut with `plate.dxf`. Again, ignore contour, cutout pockets. Cut down 6mm
   from the surface of previous cut.
![ins5][ins5]
6. Take off the block and fix it with `back_holder`, then cut it with
   `bottom_cutout.dxf`. Cut down until the thickness of top becomes 5mm.
![ins6][ins6]
![ins7][ins7]
7. Make a hole at back of the block. I did it manually with dremel.
8. Take off the result. Sand and finish it with oil stain and varnish.

[look1]: https://github.com/jinhwanlazy/wood-case-keyboard/raw/master/pics/IMG_2556.JPG "look1"
[ins2]: https://github.com/jinhwanlazy/wood-case-keyboard/raw/master/pics/IMG_2502.JPG "ins2"
[ins3]: https://github.com/jinhwanlazy/wood-case-keyboard/raw/master/pics/IMG_2507.JPG "ins3"
[ins4]: https://github.com/jinhwanlazy/wood-case-keyboard/raw/master/pics/IMG_2511.JPG "ins4"
[ins5]: https://github.com/jinhwanlazy/wood-case-keyboard/raw/master/pics/IMG_2514.JPG "ins5"
[ins6]: https://github.com/jinhwanlazy/wood-case-keyboard/raw/master/pics/IMG_2518.JPG "ins6"
[ins7]: https://github.com/jinhwanlazy/wood-case-keyboard/raw/master/pics/IMG_2519.JPG "ins7"

