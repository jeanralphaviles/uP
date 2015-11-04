#ifndef HELPERS_H
#define HELPERS_H

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include "ebi_driver.h"

#define  IOP_START    0x8000
#define  IOP_SIZE     0x2000
#define  SRAM32_START	0x472000
#define  SRAM32_SIZE  0x8000


void delay_ms(int ms) {
	for (int i = 0; i < ms; ++i) {
		for (uint16_t j = 0; j < 390; ++j) {
			asm volatile("nop");
		}
	}
}

char* uint_string(uint16_t n, char* s, int radix, int len) {
	for (int i = 0; i < len; ++i) {
		s[i] = '\0';
	}
	if (n == 0) {
		s[0] = '0';
		return s;
	}
	int i = 0;
	while (n > 0) {
		char tmp = (n % radix) + '0';
		if (tmp > '9') {
			tmp = tmp - '9' - 1 + 'A';
		}
		s[i++] = tmp;
		n /= radix;
	}
	len = i;
	for(i = i - 1; i >= len/2; --i) {
		char tmp = s[i];
		s[i] = s[len - 1 - i];
		s[len -1 - i] = tmp;
	}
	return s;
}


void init(void) {
	// Output address lines and chip selects
	PORTH_DIR = 0b110111; // /WE, /RE, /CS0, /CS1 outputs
	PORTH_OUTSET = 0b110011; // Output 1 to active low outputs
	PORTJ_DIR = 0xFF; // Set D7-D0 as outputs
	PORTK_DIR = 0xFF; // Set A15-A0 as outputs
	EBI_CTRL = 0x01; // Select 3 port SRAM ALE Mode
	// Switches and LEDS
	EBI_CS0_CTRLA = 0b0010101; // Set CTRLA to 8K size
	EBI_CS0_BASEADDR = (uint16_t)((IOP_START >> 8) & 0xFFFF); // Set upper 12 bits of baseaddr.
	// 32K SRAM + Block
	EBI_CS1_CTRLA = 0b100001; // Set CS1 to 64K
	EBI_CS1_BASEADDR = (uint16_t)((0x470000 >> 8) & 0xFFFF); // Set upper 12 of baseaddr.
	// Zero out LEDs
	__far_mem_write(IOP_START, 0x00);
}

void intmask_set(uint8_t mask) {
	PMIC_CTRL = mask;
}

void enable_int(void) {
	sei();
}

void disable_int(void) {
	cli();
}

void sleep_mode_set(uint8_t mode) {
	set_sleep_mode(mode);
}

void enable_sleep() {
	sleep_enable();
}

void sleep() {
	sleep_cpu();
}

void disable_sleep() {
	sleep_disable();
}

#endif
