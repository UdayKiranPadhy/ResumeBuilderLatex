LATEXMK := latexmk
FLAGS   := -pdf -interaction=nonstopmode -halt-on-error -file-line-error

VARIANTS := backend aiml
PDFS     := $(addprefix resume-,$(addsuffix .pdf,$(VARIANTS)))
SHARED   := preamble.tex custom-commands.tex $(wildcard src/*.tex)

.PHONY: all backend aiml watch clean

all: $(PDFS)

backend: resume-backend.pdf
aiml:    resume-aiml.pdf

resume-%.pdf: resume-%.tex $(SHARED)
	$(LATEXMK) $(FLAGS) $<

watch:
	$(LATEXMK) $(FLAGS) -pvc resume-backend.tex

clean:
	$(LATEXMK) -C
	rm -f *.aux *.log *.out *.fls *.fdb_latexmk *.synctex.gz *.toc *.bbl *.blg *.run.xml *.bcf
