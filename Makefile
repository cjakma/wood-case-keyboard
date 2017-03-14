MODEL_DIR = model
STL_DIR = stl
GCODE_DIR = gcode

PYCAM = pycam-0.5.1/pycam
SCAD = openscad-nightly

VPATH = $(MODEL_DIR):$(STL_DIR):$(GCODE_DIR)
STL_TARGETS = $(patsubst $(MODEL_DIR)/%.scad,$(STL_DIR)/%.stl,$(wildcard $(MODEL_DIR)/*.scad))
STL_TARGETS := $(filter-out $(STL_DIR)/params.stl,$(STL_TARGETS))
STL_TARGETS := $(filter-out $(STL_DIR)/preview.stl,$(STL_TARGETS))
STL_TARGETS := $(filter-out $(STL_DIR)/plate.stl,$(STL_TARGETS))

GCODE_TARGETS = base_left_rough.gcode \
				base_left_finish.gcode \
				base_right_rough.gcode \
				base_right_finish.gcode \
				top_cutout_rough.gcode \
				top_cutout_finish.gcode
				# bottom_cutout_rough.gcode

COMMON_CONF = --number-of-processes=4\
			  --progress=bar\
			  --tool-shape=cylindrical\
			  --process-milling-style=ignore\
			  --safety-height=35\
			  --bounds-type=custom\
			  --gcode-no-start-stop-spindle\
			  --gcode-path-mode=exact_path

ROUGH_CONF = --boundary-mode=inside \
			 --tool-size=6 \
			 --tool-feedrate=1400 \
			 --process-path-direction=x \
			 --process-path-strategy=layer \
			 --process-material-allowance=0.5 \
			 --process-step-down=1 \
			 --process-overlap-percent=60 \

FINISH_6_CONF = --boundary-mode=inside \
			  --tool-size=6 \
			  --tool-feedrate=2000 \
			  --process-path-direction=y \
			  --process-path-strategy=surface \
			  --process-material-allowance=0.5 \
			  --process-overlap-percent=20 \

FINISH_1_CONF = --boundary-mode=inside \
			  --tool-size=1 \
			  --tool-feedrate=2000 \
			  --process-path-direction=y \
			  --process-path-strategy=surface \
			  --process-material-allowance=0.5 \
			  --process-overlap-percent=50 \

BOUND_L = --bounds-lower=-5,0,8 \
		  --bounds-upper=160,130,34
BOUND_L_FINISH = --bounds-lower=-5,-4,8 \
				 --bounds-upper=160,125,34
BOUND_R = --bounds-lower=80,0,8 \
		  --bounds-upper=245,130,34
BOUND_R_FINISH = --bounds-lower=80,-4,8 \
				 --bounds-upper=245,125,34
BOUND_P = --bounds-lower=-0.5,-0.5,-0.5 \
		  --bounds-upper=287.15,95.75,34
BOUND_TOP = --bounds-lower=-0.5,-0.5,0 \
			--bounds-upper=286.75,96.25,34



.PHONY: all stl clean
all: $(STL_TARGETS) $(GCODE_TARGETS)

stl: $(STL_TARGETS)

gcode: $(GCODE_TARGETS)

$(STL_DIR)/%.stl: %.scad 
		mkdir -p $(STL_DIR)
		$(SCAD) -o $@ $<

$(GCODE_DIR)/base_left_rough.gcode: base_left.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(ROUGH_CONF) $(BOUND_L) $<

$(GCODE_DIR)/base_left_finish.gcode: base_left.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(FINISH_6_CONF) $(BOUND_L) $<

$(GCODE_DIR)/base_right_rough.gcode: base_right.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(ROUGH_CONF) $(BOUND_R) $<

$(GCODE_DIR)/base_right_finish.gcode: base_right.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(FINISH_6_CONF) $(BOUND_R) $<
	
$(GCODE_DIR)/top_cutout_rough.gcode: top_cutout.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(ROUGH_CONF) $(BOUND_TOP) $<

$(GCODE_DIR)/top_cutout_finish.gcode: top_cutout.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(FINISH_1_CONF) $(BOUND_TOP) $<

$(GCODE_DIR)/bottom_cutout_rough.gcode: bottom_cutout.stl
		mkdir -p $(GCODE_DIR)
		$(PYCAM) --export-gcode=$@ $(COMMON_CONF) $(ROUGH_CONF) $(BOUND_P) $<

clean:
		rm stl/*
		rm gcode/*

