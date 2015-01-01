# Makefile for sounds

LAME=lame

.SUFFIXES: .wav .mp3

.wav.mp3:
	$(LAME) $< $@

SOUNDS=goal.mp3 ending.mp3

all: $(SOUNDS)

clean:
	-$(RM) $(SOUNDS)

goal.mp3: goal.wav
ending.mp3: ending.wav
