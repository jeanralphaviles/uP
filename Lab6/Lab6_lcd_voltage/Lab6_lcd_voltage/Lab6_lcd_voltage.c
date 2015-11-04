/*
* Lab6_lcd_voltage.c
* LCD Voltage Reader
* Created: 10/27/2015 12:24:48 PM
*  Author: Jean-Ralph Aviles
*/

#include "helpers.h"
#include "ebi_driver.h"
#include "lcd.h"
#include "adc.h"

int main(void) {
	init();
	init_adc();
	init_lcd();
	char val[10];
	while (1) {
		int x = convert(read_adc());
		__far_mem_write(IOP_START, x);
		uint_string(x, val, 10, 10);
		int len = 0;
		for (len = 0; val[len] != '\0'; ++len);
		int i;
		for (i = 0; i < len - 2; ++i) {
			lcd_write_c(val[i++]);
		}
		lcd_write_c('.');
		lcd_write_s(val + i);
		lcd_write_s(" V ");
		uint_string(x, val, 16, 10);
		lcd_write_s("(0x");
		lcd_write_s(val);
		lcd_write_s(")\nPart B");
		delay_ms(500);
		lcd_clear();
	}
	return 0;
}
