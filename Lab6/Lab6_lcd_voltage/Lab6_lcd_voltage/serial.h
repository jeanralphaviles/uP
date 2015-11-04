#ifndef SERIAL_H
#define SERIAL_H

#include <avr/interrupt.h>

#define BSCALE -7
#define BSEL 1539

static volatile char last_serial = '\0';

void init_usart(void) {
	PORTD_DIRSET = 0x08;  // Tx to output
	PORTD_OUTSET = 0x08;  // Tx default output
	PORTD_DIRCLR = 0x04;  // Rx to input
	PORTQ_DIRSET = 0x0A;  // PortD -> USB
	PORTQ_OUTCLR = 0x0A;  // Default output
	USARTD0_CTRLB = 0x18; // Enable Rx, Tx
	USARTD0_CTRLC = 0x03; // No Parity, 1 stop bit.
	USARTD0_BAUDCTRLA = BSEL & 0xFF; // BSEL
	USARTD0_BAUDCTRLB = (((BSCALE << 4) & 0xF0) | ((BSEL >> 8) & 0x0F));
	USARTD0_CTRLA = 0x30; // High level interrupts for Rx
}

void serial_send(uint8_t data) {
	while ((USARTD0_STATUS & 0x20) == 0) {
	}
	USARTD0_DATA = data;
}

void serial_send_s(char* string) {
	while (*string) {
		serial_send(*(string++));
	}
} 

ISR(USARTD0_RXC_vect) {
	last_serial = USARTD0_DATA;
}

#endif