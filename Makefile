export PATH := $(PATH):/Applications/LyX.app/Contents/MacOS/
SHELL = /bin/bash

LATEX=latexmk -f -interaction=nonstopmode -pdf -xelatex --synctex=1

LYXS=$(wildcard includes/*.lyx)
LYXINCLUDES=$(patsubst %.lyx,%.bare_tex,$(LYXS))
TEXS=$(wildcard includes/*.tex)
TEXINCLUDES=$(patsubst %.tex,%.bare_tex,$(TEXS))

formulary.pdf: formulary.tex includes.tex

includes.tex: $(LYXINCLUDES) $(TEXINCLUDES) preamble.sty macros.sty
	ls includes/*.bare_tex | sed 's/\(.*\)/\\input{\1}/' > $@

%.pdf: %.tex
	$(LATEX) $< -jobname=$(basename $@ .pdf)

includes/%.tex: includes/%.lyx
	lyx --export xetex $<

# remove newlines so sed can work multiline, cut everyting until
# \begin{document}, add newlines back and remove the outside document env. Now
# its suitable for \input-ing from another file.
# TODO https://stackoverflow.com/questions/35965783/
includes/%.bare_tex: includes/%.tex
	cat $< |\
		tr '\n' '\r' |\
		sed 's/^.*\\begin{document}//' |\
		tr '\r' '\n' |\
		sed -e 's/\\end{document}//' > $@

# it is what it is
clean_trash:
	find . -name '*.aux' -delete
	find . -name '*.auxlock' -delete
	find . -name '*.fdb_latexmk' -delete
	find . -name '*.fls' -delete
	find . -name '*.xdv' -delete
	find . -name '*.log' -delete
	find . -name '*.out' -delete
	find . -name '*.synctex.gz' -delete
	find . -name '*.bare_tex' -delete
	find . -name 'includes.tex' -delete

clean: clean_trash
	find . -name 'formulary.pdf' -delete
