.PHONY: all clean

all: long_wall.pdf

long_wall.pdf: long_wall.tex
	pdflatex -interaction=nonstopmode -halt-on-error long_wall.tex
	pdflatex -interaction=nonstopmode -halt-on-error long_wall.tex

clean:
	rm -f long_wall.aux long_wall.log long_wall.out long_wall.toc long_wall.synctex.gz
