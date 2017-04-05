MODEL_DIR = model
OUT_DIR = out
VPATH = $(MODEL_DIR):$(OUT_DIR)

LAYOUT = hhkb
SCAD = openscad-nightly
STL_TARGET = base tilt_holder back_holder
DXF_TARGET = top_cutout bottom_cutout plate

STL_TARGET := $(foreach f,$(STL_TARGET),$(OUT_DIR)/$(f).stl)
DXF_TARGET := $(foreach f,$(DXF_TARGET),$(OUT_DIR)/$(f).dxf)
LAYOUT := layout/$(LAYOUT).layout
LAYOUT_TARGET = $(MODEL_DIR)/params.scad

.PHONY: all stl layout clean
all: $(STL_TARGET) $(DXF_TARGET) $(LAYOUT_TARGET)

stl: $(STL_TARGET) $(LAYOUT_TARGET)

dxf: $(DXF_TARGET) $(LAYOUT_TARGET)

$(LAYOUT_TARGET): $(LAYOUT)
		python3 layout_parser.py $(LAYOUT) > $@

$(OUT_DIR)/%.stl: %.scad 
		mkdir -p $(OUT_DIR)
		$(SCAD) -o $@ $<

$(OUT_DIR)/%.dxf: %.scad 
		mkdir -p $(OUT_DIR)
		$(SCAD) -o $@ $<

clean:
		rm $(OUT_DIR)/*

