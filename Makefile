MODEL_DIR = model
STL_DIR = stl
GCODE_DIR = gcode

PYCAM = pycam-0.5.1/pycam
SCAD = openscad-nightly

VPATH = $(MODEL_DIR):$(STL_DIR):$(GCODE_DIR)
STL_TARGETS = $(patsubst $(MODEL_DIR)/%.scad,$(STL_DIR)/%.stl,$(wildcard $(MODEL_DIR)/*.scad))
STL_TARGETS := $(filter-out $(STL_DIR)/params.stl,$(STL_TARGETS))
STL_TARGETS := $(filter-out $(STL_DIR)/preview.stl,$(STL_TARGETS))

GCODE_TARGETS = shape_left_rough.gcode
				# shape_left_finish.gcode
GCODE_TARGETS := $(patsubst %.gcode,$(GCODE_DIR)/%.gcode,$(GCODE_TARGETS))

COMMON_CONF = --boundary-mode=outside \
			--number-of-processes=4\
			--progress=bar\
			--tool-shape=cylindrical\
			--process-milling-style=ignore\
			--safety-height=35\
			--bounds-type=custom\
			--gcode-no-start-stop-spindle\
			--gcode-path-mode=exact_path

ROUGH_CONF = --tool-size=6 \
			 --tool-feedrate=1400 \
			 --process-path-direction=xy \
			 --process-path-strategy=layer \
			 --process-material-allowance=0.5 \
			 --process-step-down=1 \
			 --process-overlap-percent=60 \

FINISH_CONF = --tool-size=6 \
			  --tool-feedrate=2000 \
			  --process-path-direction=x \
			  --process-path-strategy=surface \
			  --process-material-allowance=0.1 \
			  --process-overlap-percent=90 \

BOUND = --bounds-lower=0,0,-0.5 \
		--bounds-upper=330,130,34
BOUND_L = --bounds-lower=0,0,-0.5 \
		  --bounds-upper=160,130,34
BOUND_R = --bounds-lower=80,0,-0.5 \
		  --bounds-upper=250,130, 34
BOUND_P = --bounds-lower=-0.5,-0.5,-0.5 \
		  --bounds-upper=287.15,95.75,34


.PHONY: all gcode clean
all: $(STL_TARGETS)

gcode: $(GCODE_TARGETS)

$(STL_DIR)/%.stl: %.scad 
		mkdir -p $(STL_DIR)
		$(SCAD) -o $@ $<

$(GCODE_DIR)/shape_rough.gcode: shape.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(ROUGH_CONF) $(BOUND) $<

$(GCODE_DIR)/shape_finish.gcode: shape.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(FINISH_CONF) $(BOUND) $<

$(GCODE_DIR)/shape_left_rough.gcode: shape_left.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(ROUGH_CONF) $(BOUND_L) $<

$(GCODE_DIR)/shape_left_finish.gcode: shape_left.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(FINISH_CONF) $(BOUND_L) $<

clean:
		rm stl/*
		rm gcode/*

