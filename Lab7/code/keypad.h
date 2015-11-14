#ifndef KEYPAD_H
#define KEYPAD_H

#include <avr/io.h>
#include <avr/interrupt.h>
#include "helpers.h"

char KEYTAB[4][4] = {
	{'1', '2', '3', 'A'},
	{'4', '5', '6', 'B'},
	{'7', '8', '9', 'C'},
	{'*', '0', '#', 'D'}
};

static volatile char last_key = '\0';

void init_keypad(void);
char read_keypad(void);

void init_keypad(void) {
	PORTF_DIR = 0xF0;
	PORTCFG_MPCMASK = 0x0F;
	// High Level Interrupt on Key press.
	PORTF_PIN0CTRL = 0x11;
	PORTF_INTCTRL = 0x03;
	PORTF_INT0MASK = 0x0F;
	PORTF_OUT = 0xF0;
}

char read_keypad(void) {
	for (int i = 0; i < 4; ++i) {
		PORTF_OUT = (0b0001 << i) << 4;
		for (int j = 0; j < 4; ++j) {
			asm volatile("nop\nnop\nnop");
			if (PORTF_IN & (0b0001 << j)) {
				PORTF_OUT = 0xF0;
				return KEYTAB[i][j];
			}
		}
	}
	PORTF_OUT = 0xF0;
	return 'F';
}

ISR(PORTF_INT0_vect) {
	delay_ms(1); // Debounce
	char tmp = read_keypad();
	if (tmp != 'F') {
		last_key = tmp;
	}
	PORTF_INTFLAGS |= 0x01;
}

#endif
