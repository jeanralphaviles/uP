#ifndef SPEAKER_H
#define SPEAKER_H

#include <avr/io.h>

/* Returns CCA value for frequency, slightly tuned */
#define _frequency(x) ((int)((1000000)/(x))+10)

#define C5	523.25
#define C5S 554.37
#define D5  587.33
#define D5S 622.25
#define E5  659.25
#define F5  698.46
#define F5S 739.99
#define G5  783.99
#define G5S 830.61
#define A5  880.00
#define A5S 932.33
#define B5  987.77

#define C6  1046.50
#define C6S 1108.73
#define D6  1174.66
#define D6S 1244.51
#define E6  1318.51
#define F6  1396.91
#define F6S 1479.98
#define G6  1567.98
#define G6S 1661.22
#define A6  1760.00
#define A6S 1864.66
#define B6  1975.53

#define C7  2093.00
#define C7S 2217.46
#define D7  2349.32
#define E7  2637.02

typedef int note;

void init_speaker(void);
void play_note(note,uint16_t);
void set_frequency(float);
void enable_speaker(void);
void disable_speaker(void);

void init_speaker(void) {
  PORTE_DIRSET = 0x08;  // Pin3 Output
  TCE0_CTRLA = 0x01;    // Prescaler = CLK
  TCE0_CTRLD = 0x80;    // Restart Waveform
  TCE0_CTRLB = 0x01;    // FRQ Generation
}

void play_note(note n, uint16_t dur_ms) {
  set_frequency(n);
  enable_speaker();
  delay_ms(dur_ms);
  disable_speaker();
}

void set_frequency(float freq) {
  TCE0_CCA = _frequency(freq);
}

void enable_speaker(void) {
  TCE0_CTRLB |= 0x80;
}

void disable_speaker(void) {
  TCE0_CTRLB &= ~0x80;
}

#endif
