
ANIM_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

SVGS ?= $(shell ls *.svg)

all: svg_anim.mk

svg_anim.mk: $(SVGS)
	echo "# Animation steps for $(SVGS)" >$@; \
	echo "PDFS :=" >>$@; \
	echo "PNGS :=" >>$@; \
	for svg in $(SVGS); do \
	  cnt=0; \
	  python3 $(ANIM_DIR)/get_anim_layers.py $$svg | while read line; do \
	    pdf=$${svg%.svg}.$$cnt.pdf; \
	    png=$${svg%.svg}.$$cnt.png; \
	    echo ""; \
	    echo "PDFS += $$pdf"; \
	    echo "PNGS += $$png"; \
	    echo "$$pdf $$png: $$svg"; \
	    printf '\tinkscape --actions="%s %s %s" $$<\n' \
			       "select-all:layers; selection-hide; select-clear;" \
	           "`echo $$line | sed 's/\([^ ]*\) */select-by-id:\1; /g'`selection-unhide;" \
	           "export-area-page; export-filename:\$$@; export-do"; \
	    cnt=$$((cnt+1)); \
	  done; \
	done >>$@;

-include svg_anim.mk

.PHONY: all pdf png
all: pdf png

pdf: $(PDFS)
png: $(PNGS)
