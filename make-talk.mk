# Check header for which formats to create in notes and slides.
# CReate PDF Of reveal slides with something like decktape https://github.com/astefanutti/decktape

OUT=$(DATE)-$(BASE)
DEPS=$(shell ../dependencies.py inputs $(BASE).md)
DIAGDEPS=$(shell ../dependencies.py diagrams $(BASE).md)
BIBDEPS=$(shell ../dependencies.py bibinputs $(BASE).md)
POSTFLAGS=$(shell ../flags.py post $(BASE))
PPTXFLAGS=$(shell ../flags.py pptx $(BASE))
DOCXFLAGS=$(shell ../flags.py docx $(BASE))
ALL=$(shell ../dependencies.py all $(BASE).md)

all: $(ALL)

##${BASE}.notes.tex ${BASE}.notes.pdf 

${BASE}.slides.html: ${BASE}.slides.html.markdown ${BIBDEPS}
	printf '' > ../include.tmp
	printf '\[' >> ../include.tmp
	cat ../_includes/talk-notation.tex >> ../include.tmp
	printf '\]' >> ../include.tmp
	printf '' >> ../include.tmp
	#pandoc  --template pandoc-revealjs-template ${PDSFLAGS} ${SFLAGS} -c ${CSS} --include-in-header=${SLIDESHEADER} -t revealjs --bibliography=../lawrence.bib --bibliography=../other.bib --bibliography=../zbooks.bib -o ${BASE}.slides.html  ${BASE}.slides.html.markdown 
	pandoc  -B ../include.tmp --template pandoc-revealjs-template ${PDSFLAGS} ${SFLAGS} -c ${CSS} --include-in-header=${SLIDESHEADER} -t revealjs --bibliography=../lawrence.bib --bibliography=../other.bib --bibliography=../zbooks.bib -o ${BASE}.slides.html  ${BASE}.slides.html.markdown 
	cp ${BASE}.slides.html ../slides/${OUT}.slides.html
	rm ../include.tmp

${BASE}.pptx: ${BASE}.slides.pptx.markdown 
	pandoc  -t pptx \
		-o $@ $< \
		-B ../_includes/talk-notation.tex \
		${PPTXFLAGS} \
		${CITEFLAGS} \
		${SFLAGS} 

${BASE}.notes.pdf: ${BASE}.notes.aux ${BASE}.notes.bbl ${BASE}.notes.tex
	pdflatex -shell-escape ${BASE}.notes.tex
	cp ${BASE}.notes.pdf ../_notes/${OUT}.notes.pdf

${BASE}.notes.bbl: ${BASE}.notes.aux ${BIBDEPS}
	bibtex ${BASE}.notes

${BASE}.notes.aux: ${BASE}.notes.tex
	pdflatex -shell-escape ${BASE}.notes.tex


${BASE}.notes.tex: ${BASE}.notes.tex.markdown 
	pandoc  -s \
		--template pandoc-notes-tex-template.tex \
		--number-sections \
		--natbib \
		${BIBFLAGS} \
		-B ../_includes/talk-notation.tex \
		-o ${BASE}.notes.tex  \
		${BASE}.notes.tex.markdown 

${BASE}.docx: ${BASE}.notes.docx.markdown ${BIBDEPS} ${DIAGDEPS}
	pandoc  ${CITEFLAGS} \
		--to docx \
		-B ../_includes/talk-notation.tex \
		${DOCXFLAGS} \
		--out ${BASE}.docx  \
		${BASE}.notes.docx.markdown 

${BASE}.notes.html: ${BASE}.notes.html.markdown ${BIBDEPS}
	pandoc  ${PDSFLAGS} \
		-o ${BASE}.notes.html  \
		${BASE}.notes.html.markdown 

${BASE}.posts.html: ${BASE}.notes.html.markdown
	pandoc --template pandoc-jekyll-talk-template ${PDFLAGS} \
	       --atx-headers \
	       ${POSTFLAGS} \
               --bibliography=../lawrence.bib \
               --bibliography=../other.bib \
               --bibliography=../zbooks.bib \
               --to html \
               --out ${BASE}.posts.html  ${BASE}.notes.html.markdown 
	cp ${BASE}.posts.html ../_posts/${OUT}.html


${BASE}.ipynb: ${BASE}.notes.ipynb.markdown
	pandoc  --template pandoc-jekyll-ipynb-template ${PDFLAGS} \
		--atx-headers \
		-B ../_includes/talk-notation.tex \
		${CITEFLAGS} \
		--out ${BASE}.tmp.markdown  ${BASE}.notes.ipynb.markdown
	notedown ${BASE}.tmp.markdown > ${BASE}.ipynb
	cp ${BASE}.ipynb ../_notebooks/${OUT}.ipynb
	rm ${BASE}.tmp.markdown

${BASE}.slides.ipynb: ${BASE}.slides.ipynb.markdown
	pandoc  --template pandoc-jekyll-ipynb-template ${PDFLAGS} \
		--atx-headers \
		-B ../_includes/talk-notation.tex \
		${CITEFLAGS} \
		--out ${BASE}.tmp.markdown  ${BASE}.slides.ipynb.markdown
	notedown ${BASE}.tmp.markdown > ${BASE}.slides.ipynb
	cp ${BASE}.slides.ipynb ../_notebooks/${OUT}.slides.ipynb
	rm ${BASE}.tmp.markdown


%.slides.pptx.markdown: %.md ${DEPS}
	${PP} $< -o $@ --to pptx --format slides ${PPFLAGS} -B ../_includes/talk-notation.tex

%.slides.html.markdown: %.md ${DEPS}
	${PP} $< -o $@ --to html --format slides ${PPFLAGS} 

%.notes.html.markdown: %.md ${DEPS}
	${PP} $< -o $@ --format notes --to html ${PPFLAGS} 

%.notes.tex.markdown: %.md ${DEPS}
	${PP} $< -o $@ --format notes --to tex ${PPFLAGS} 
	# Fix percentage width for latex.
	sed -i -e 's/width=\(.*\)\%/width=0.\1\\textwidth/g' $@
	sed -i -e 's/height=\(.*\)\%/height=0.\1\\textheight/g' $@

%.notes.docx.markdown: %.md ${DEPS}
	${PP} $< -o $@ --format notes --to docx ${PPFLAGS} 

%.notes.ipynb.markdown: %.md ${DEPS}
	${PP} $< -o $@ --format notes --to ipynb ${PPFLAGS} 

%.slides.ipynb.markdown: %.md ${DEPS}
	${PP} $< -o $@ --format slides --to ipynb ${PPFLAGS} 


%.svg: %.svgi
	${PP} $< -o $@ --format notes --to svg ${PPFLAGS} --include-before-body ../svgi-includes.gpp  --no-header

%.pdf: %.svg
	${INKSCAPE} ${PWD}/$< --export-pdf=${PWD}/$@ --without-gui

%.png: %.svg
	${INKSCAPE} ${PWD}/$< --export-png=${PWD}/$@ --without-gui

%.emf: %.svg
	${INKSCAPE} ${PWD}/$< --export-emf=${PWD}/$@ --without-gui

clean:
	rm *.markdown
	rm *.markdown-e
	rm ${ALL}
