# Makefile — regenerate the CCA Vintage-2026 futures figures from the ICE CSVs.
#
# Run from this directory (figure/code/):
#   make          build any figure whose .do file or input CSV changed
#   make all      same as `make`
#   make dec26    build only the December-2026 delivery figure
#   make may26    build only the May-2026 delivery figure
#   make clean    delete the generated PNGs
#
# All Stata paths are relative to figure/code/:  ../input/<csv>  ->  ../output/<png>

SHELL := /bin/bash          # shell_functions.sh uses bash features

INPUT  := ../input
OUTPUT := ../output

FIGS := $(OUTPUT)/fig_price_dec26.png $(OUTPUT)/fig_price_may26.png

.PHONY: all dec26 may26 clean
all: $(FIGS)

dec26: $(OUTPUT)/fig_price_dec26.png
may26: $(OUTPUT)/fig_price_may26.png

$(OUTPUT)/fig_price_dec26.png: fig_price_dec26.do $(INPUT)/cca_v26_dec26_ice.csv
	source shell_functions.sh && stata_with_flag fig_price_dec26.do

$(OUTPUT)/fig_price_may26.png: fig_price_may26.do $(INPUT)/cca_v26_may26_ice.csv
	source shell_functions.sh && stata_with_flag fig_price_may26.do

clean:
	rm -f $(FIGS)
