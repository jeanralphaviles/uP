/*
 * Lab6_2.c
 *
 * Created: 10/27/2015 12:24:48 PM
 *  Author: Jean-Ralph Aviles
 */ 

#include "helpers.h"
#include "lcd.h"

int main() {
	init();
	init_lcd();
	while(1) {
    lcd_clear();
		lcd_write_s("Jean-Ralph\nPart A");
		delay_ms(1000);
	}
	return 0;
}