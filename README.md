![look1][look1]

# Brief
This is a hobby project, to make a copy of HHKB made of wood,
but not limited to it. It is fully customizable, parameterized
toolchain to generate a keyboard case.

# Features
- Made of wood
- Nice curved shape
- Opened bottom (minimizing overall height and show off your PCB!)

# Dependancies
- python3
- [python-shapely](https://pypi.python.org/pypi/Shapely)
- [Openscad](http://www.openscad.org/) -- nightly version is recommended
- [OskarLinde/scad-utils](https://github.com/OskarLinde/scad-utils)
- [openscad/list-comprehension-demos](https://github.com/openscad/list-comprehension-demos)

# Build
Open `model/common.sacd` and modify parameters. You have to set `block_size`
properly even if you don't want to change anything. See
[Customization](#customization) before modifying the file.

Following command will generate all 3D and 2D models you need in
`stl` and `dxf` format, under `out` directory. After you excecute `make` 
successfuly, you can open up `model/preview.scad` and see how will it look
like.

    git clone https://github.com/jinhwanlazy/wood-case-keyboard
    cd wood-case-keyboard
    make

If your are using OSX, you might have to specify full path of openscad.

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
I have used a [Shapeoko1](https://www.shapeoko.com/shapeoko1.html) built
myself, and [PyCam](http://pycam.sourceforge.net/) to generate 
gcodes. It was painfull job.
I have to manually modify output gcodes every time.
I have made mistakes(forgetting change
bits, feeding wrong gcode), and encountered number of hardware problems(slipping
bits, burning wood, missing steps, etc). I had to make monkeypatchs everytime
something goes wrong. I highly recommend you to use commercial grade
toolchains or just talk with manufacturer.  I'll leave here very brief steps
I have made, rather than full instruction. 

1. Print `back_holder.stl` and `tilt_holder.stl` with a 3D printer.
2. Fix wood block on CNC mill, and carve it with `base.stl`. (I had to split it
   two pieces)
3. Fix a pair of `tilt_holder` with screw at bottom of the wood block.
4. Place wood block again, and cut with `top_cutout.dxf`.
Cut depth `lip_depth`mm from the highest point of the woodblock. It is
defined in `common.scad`.
The size of the model is arbitrary. Ignore the contour.
You have to cutout only pockets of the model.
The origin of the model is set to bottom left most key's corner.
5. Cut with `plate.dxf`. Again, ignore contour, cutout pockets. Cut down 6mm
   from the surface of previous cut.
6. Take off the block and fix it with `back_holder`, then cut it with
   `bottom_cutout`. Cut down until the thickness of top becomes 5mm.
7. Take off the result. Sand and finish it.

[look1]: https://github.com/jinhwanlazy/wood-case-keyboard/raw/master/pics/IMG_2556.JPG "look1"
