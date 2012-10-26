## Variables
#

# paths:
BIN_DIR = ./bin
OUT_DIR = ./out
SRC_DIR = ./src

MINIFY = 1

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

.PHONY: all min dev help clean css css-min js js-min

# bundle all CSS and JS targets:
all: css js

# minify all CSS and JS targets:
min: css-min js-min

# just like "min" target above, but don't actually minify the files (that is,
# the *.min.* file is the same as the source/unminified counterpart):
dev: MINIFY = 0
dev: css-min js-min

# some help:
help:
	@@echo "Available targets:"
	@@echo ""
	@@echo "  all (default) - bundle all CSS and JS targets"
	@@echo "  min           - minify all CSS and JS targets"
	@@echo "  dev           - *.min.* files are built but they're not actually minified"
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
	$(if $(subst 0,,$(MINIFY)),@@$(BIN_DIR)/yuiminify $< > $@,@@cp $< $@)

# generic rule to minify JS:
%.min.js: %.js
	@@echo "Minifying [$@]..."
	$(if $(subst 0,,$(MINIFY)),@@$(BIN_DIR)/googleminify $< > $@,@@cp $< $@)

