fontsize = 12pt
lang = ru
dpi = 96

SHELL = /bin/sh


PANDOC = pandoc

PANDOC_PDF_STYLE = lang=$(lang) \
documentclass=extarticle \
margin-left=15mm \
margin-right=15mm \
margin-top=15mm \
margin-bottom=20mm \
papersize=a4 \
fontsize=$(fontsize) \
mainfont='STIX_Two_Text' \
sansfont='PT_Sans' \
monofont='PT_Mono' \
mathfont='STIX_Two_Math'

PANDOC_PDF_FLAGS = --pdf-engine=xelatex \
$(subst _, ,$(addprefix -M ,$(PANDOC_PDF_STYLE)))

%.pdf: %.md
	$(PANDOC) $(PANDOC_FLAGS) $(PANDOC_PDF_FLAGS) -o $@ $<

pdf-from-md: $(patsubst %.md,%.pdf,$(wildcard *.md))

.PHONY: pdf-from-md


SHDOC = ~/bin/shdoc

%.md: %.sh
	$(SHDOC) $(SHDOC_FLAGS) $< > $@

pdf-from-sh: $(patsubst %.sh,%.pdf,$(wildcard *.sh))

.PHONY: pdf-from-sh


MAGICK = magick
MAGICK_JPG_FLAGS = -strip -density $(dpi) -units PixelsPerInch \
-quality 95 -interlace JPEG
MAGICK_PNG_FLAGS = -interlace PNG

%.jpg: %.png
	$(MAGICK) $< $(MAGICK_JPG_FLAGS) $@

multiview-layout = $(firstword $(1)) \( $(wordlist 2,4,$(1)) -append \) \
$(wordlist 5,6,$(1)) -gravity center +append

%-multiview.png: %-left.png %-top.png %-front.png %-bottom.png %-right.png %-back.png
	$(MAGICK) $(call multiview-layout,$^) $(MAGICK_PNG_FLAGS) $@

jpg-from-png: $(patsubst %.png,%.jpg,$(wildcard *.png))

.PHONY: jpg-from-png


FLAC = flac

%.wav: %.flac
	$(FLAC) $(FLAC_FLAGS) -d -o $@ $<


LAME = lame
LAME_FLAGS = --nohist --preset extreme

%.mp3: %.wav
	$(LAME) $(LAME_FLAGS) $< $@

mp3-from-wav: $(patsubst %.wav,%.mp3,$(wildcard *.wav))
mp3-from-flac: $(patsubst %.flac,%.mp3,$(wildcard *.flac))

.PHONY: mp3-from-wav mp3-from-flac


FDKAAC = fdkaac
FDKAAC_FLAGS = -m 5

%.m4a: %.wav
	$(FDKAAC) $(FDKAAC_FLAGS) -o $@ $<

aac-from-wav: $(patsubst %.wav,%.m4a,$(wildcard *.wav))
aac-from-flac: $(patsubst %.flac,%.m4a,$(wildcard *.flac))

.PHONY: aac-from-wav aac-from-flac


OGGENC = oggenc
OGGENC_FLAGS = -q 8

%.ogg: %.wav
	$(OGGENC) $(OGGENC_FLAGS) -o $@ $<

ogg-from-wav: $(patsubst %.wav,%.ogg,$(wildcard *.wav))
ogg-from-flac: $(patsubst %.flac,%.ogg,$(wildcard *.flac))

.PHONY: ogg-from-wav ogg-from-flac


OPUSENC = opusenc
OPUSENC_FLAGS = --bitrate 256

%.opus: %.wav
	$(OPUSENC) $(OPUSENC_FLAGS) $< $@

opus-from-wav: $(patsubst %.wav,%.opus,$(wildcard *.wav))
opus-from-flac: $(patsubst %.flac,%.opus,$(wildcard *.flac))

.PHONY: opus-from-wav opus-from-flac


M4 = m4
M4_FLAGS = -P

%: %.m4
	$(M4) $(M4_FLAGS) $< > $@


OPENSCAD = openscad
OPENSCAD_PNG_FLAGS = --projection ortho --viewall --autocenter \
--colorscheme Tomorrow --render

%.png: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_PNG_FLAGS) -o $@ $<

%-top.png: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_PNG_FLAGS) --camera 0,0,0,0,0,0,0 -o $@ $<

%-front.png: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_PNG_FLAGS) --camera 0,0,0,90,0,0,0 -o $@ $<

%-left.png: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_PNG_FLAGS) --camera 0,0,0,90,0,-90,0 -o $@ $<

%-right.png: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_PNG_FLAGS) --camera 0,0,0,90,0,90,0 -o $@ $<

%-bottom.png: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_PNG_FLAGS) --camera 0,0,0,180,0,0,0 -o $@ $<

%-back.png: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_PNG_FLAGS) --camera 0,0,0,90,0,180,0 -o $@ $<

%-top.scad: %.scad
	echo "projection() { `cat $<` }" > $@

%-front.scad: %.scad
	echo "projection() rotate([-90,0,0]) { `cat $<` }" > $@

%-left.scad: %.scad
	echo "projection() rotate([-90,90,0]) { `cat $<` }" > $@

%-right.scad: %.scad
	echo "projection() rotate([-90,-90,0]) { `cat $<` }" > $@

%-bottom.scad: %.scad
	echo "projection() rotate([180,0,0]) { `cat $<` }" > $@

%-back.scad: %.scad
	echo "projection() rotate([90,0,0]) { `cat $<` }" > $@

%.svg: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_SVG_FLAGS) -o $@ $<

%.dxf: %.scad
	$(OPENSCAD) $(OPENSCAD_FLAGS) $(OPENSCAD_DXF_FLAGS) -o $@ $<

png-from-scad: $(patsubst %.scad,%.png,$(wildcard *.scad))
svg-from-scad: $(patsubst %.scad,%.svg,$(wildcard *.scad))
multiviews: $(patsubst %.scad,%-multiview.png,$(wildcard *.scad))

.PHONY: png-from-scad svg-from-scad multiviews


INKSCAPE = inkscape
INKSCAPE_FLAGS = -z -d $(dpi)

%.png: %.svg
	$(INKSCAPE) $(INKSCAPE_FLAGS) $(INKSCAPE_PNG_FLAGS) -e '$(abspath $@)' '$(abspath $<)'

png-from-svg: $(patsubst %.svg,%.png,$(wildcard *.svg))

.PHONY: png-from-svg


SOFFICE = soffice
SOFFICE_FLAGS = --headless

%.odt: %.doc
	$(SOFFICE) $(SOFFICE_FLAGS) $(SOFFICE_ODT_FLAGS) --convert-to odt $<

%.pdf: %.odt
	$(SOFFICE) $(SOFFICE_FLAGS) $(SOFFICE_PDF_FLAGS) --convert-to pdf $<

%.pdf: %.docx
	$(SOFFICE) $(SOFFICE_FLAGS) $(SOFFICE_PDF_FLAGS) --convert-to pdf $<

odt-from-doc: $(patsubst %.doc,%.odt,$(wildcard *.doc))

.PHONY: odt-from-doc


POTRACE = potrace -s

%.svg: %.pbm
	$(POTRACE) $(POTRACE_FLAGS) -o $@ $<


TESSERACT = tesseract
TESSERACT_FLAGS = -l rus+eng

%.txt: %.png
	$(TESSERACT) $< $(basename $@) $(TESSERACT_FLAGS)

%.txt: %.jpg
	$(TESSERACT) $< $(basename $@) $(TESSERACT_FLAGS)


PDFBOOK = pdfbook
PDFBOOK_FLAGS = --short-edge --suffix booklet

%-booklet.pdf: %.pdf
	$(PDFBOOK) $(PDFBOOK_FLAGS) $<
