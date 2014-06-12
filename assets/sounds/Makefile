# Makefile for sounds

LAME=lame

.SUFFIXES: .wav .mp3

.wav.mp3:
	$(LAME) $< $@

SOUNDS=beep.mp3

all: $(SOUNDS)

clean:
	-$(RM) $(SOUNDS)

beep.mp3: beep.wav
