#ifndef ADC_H
#define ADC_H

#include <avr/io.h>
#include "helpers.h"

void init_adc(void);
int read_adc(void);
int convert(int);

void init_adc(void) {
	ADCB_CTRLA = 0x01; // Enable ADC
	PORTA_DIRCLR = 0xFF; // Input
	PORTB_DIRCLR = 0x08; // Input
	ADCB_CTRLB = 0x0C; // Signed 8 bit mode
	ADCB_REFCTRL = 0x30; // AREFB
	ADCB_PRESCALER = 0x07; // Al-gore
	ADCB_CH0_CTRL = 0b10000001; // Singled ended input
	ADCB_CH0_MUXCTRL = 0b100000;
}

int read_adc(void) {
	ADCB_CTRLA |= 0x4;
	ADCB_CH0_CTRL = 0b10000001; // Start
	while ((ADCB_CH0_INTFLAGS & 0x01) == 0x00) {
		// Wait for completion
		break;
	}
	volatile int x = ADCB_CH0_RES;
	ADCB_CH0_INTFLAGS = 0x01; // Clear flag
	return x;
}

int convert(int i) {
	return 1.875 * i - 20;
}

#endif
