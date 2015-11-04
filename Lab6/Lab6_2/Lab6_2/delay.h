#ifndef DELAY_H
#define DELAY_H

inline void delay_ms(int ms) {
	for (int i = 0; i < ms; ++i) {
		for (uint16_t j = 0; j < 390; ++j) {
			asm volatile("nop");
		}
	}
}

#endif