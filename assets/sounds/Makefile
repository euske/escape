# Makefile for sounds

LAME=lame

.SUFFIXES: .wav .mp3

.wav.mp3:
	$(LAME) $< $@

SOUNDS=ending.mp3

all: $(SOUNDS)

clean:
	-$(RM) $(SOUNDS)

ending.mp3: ending.wav
