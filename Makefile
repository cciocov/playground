## Variables
#

# paths:
BIN_DIR = ./bin
OUT_DIR = ./out
SRC_DIR = ./src

# find all CSS and JS targets:
TARGETS_CSS = $(basename $(subst $(SRC_DIR)/,,$(shell find $(SRC_DIR)/ -name *.css.dep -type f)))
TARGETS_JS = $(basename $(subst $(SRC_DIR)/,,$(shell find $(SRC_DIR)/ -name *.js.dep -type f)))

## Functions
#

# create all rules for a target:
# $1 - target file relative to $(SRC_DIR)
define create-target-rules
$(OUT_DIR)/$1: $(call get-target-prerequisites,$1)
	@@echo "Making [$$@]..."
	@@mkdir -p $$(dir $$@)
	@@cat $$^ > $$@
endef

# get target prerequisites:
# $1 - target file relative to $(SRC_DIR)
define get-target-prerequisites
$(foreach f,$(shell cat $(SRC_DIR)/$1.dep),$(SRC_DIR)/$(dir $1)/$f)
endef


## Rules
#

.PHONY: all min help clean css css-min js js-min

# default target (all), bundle all CSS and JS targets:
all: css js

# minify all CSS and JS targets:
min: css-min js-min

# some help:
help:
	@@echo "Available targets:"
	@@echo ""
	@@echo "  all - bundle all CSS and JS targets"
	@@echo "  min - minify all CSS and JS targets"
	@@echo ""

# clean up:
clean:
	@@rm -rf $(OUT_DIR)/*

# CSS targets:
$(foreach t,$(TARGETS_CSS),$(eval $(call create-target-rules,$t)))
css: $(addprefix $(OUT_DIR)/,$(TARGETS_CSS))
css-min: $(addprefix $(OUT_DIR)/,$(addsuffix .min.css, $(basename $(TARGETS_CSS))))

# JS targets:
$(foreach t,$(TARGETS_JS),$(eval $(call create-target-rules,$t)))
js: $(addprefix $(OUT_DIR)/,$(TARGETS_JS))
js-min: $(addprefix $(OUT_DIR)/,$(addsuffix .min.js, $(basename $(TARGETS_JS))))

# generic rule to minify CSS:
%.min.css: %.css
	@@echo "Minifying [$@]..."
	@@$(BIN_DIR)/yuiminify $< > $@

# generic rule to minify JS:
%.min.js: %.js
	@@echo "Minifying [$@]..."
	@@$(BIN_DIR)/googleminify $< > $@

