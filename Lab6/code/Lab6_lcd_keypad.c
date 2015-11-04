/*
* Lab6_lcd_keypad.c
* LCD Keypad Control
* Created: 10/27/2015 12:24:48 PM
*  Author: Jean-Ralph Aviles
*/

#include "adc.h"
#include "helpers.h"
#include "keypad.h"
#include "lcd.h"
#include "serial.h"

extern volatile char last_key;
extern volatile char last_serial;

int main(void) {
	init();
	init_adc();
	init_lcd();
	init_keypad();
	init_usart();
	sleep_mode_set(SLEEP_MODE_IDLE);
	enable_sleep();
	intmask_set(0x04);
	enable_int();
	while (1) {
		switch (last_key) {
			case '0':
			case '1':
				lcd_write_s("JR\nAviles");
				sleep();
				break;
			case '2':
			case '3':
				lcd_clear();
				sleep();
				break;
			case '4':
			case '5':
				toggle_lcd();
				sleep();
				break;
			case '6':
			case '7':
				lcd_clear();
				lcd_write_s("May the Schwartzbe with you!");
				sleep();
				break;
			case '*':
			case '#':
				while (last_key == '*' || last_key == '#') {
					lcd_clear();
					char val[10];
					int x = convert(read_adc());
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
					lcd_write_c(')');
					delay_ms(500);
				}
				break;
			case 'A': ;
				bool insert_mode = FALSE;
				
				while (last_key == 'A') {
					sleep();
					if (insert_mode == TRUE) {
						if (last_serial == 0x1B) {
							insert_mode = FALSE;
						} else if (last_serial == 0x7F) {
							lcd_move_cursor(LEFT);
							lcd_write_c(' ');
							lcd_move_cursor(LEFT);
						}else {
							lcd_write_c(last_serial);
						}
					} else {
						switch (last_serial) {
							case 'h':
								lcd_move_cursor(LEFT);
								break;
							case 'k':
								lcd_move_cursor(UP);
								break;
							case 'l':
								lcd_move_cursor(RIGHT);
								break;
							case 'j':
								lcd_move_cursor(DOWN);
								break;
							case 'i':
								serial_send_s("INSERT MODE!\n\r");
								insert_mode = TRUE;
								break;
							case 0x7F:
								lcd_move_cursor(LEFT);
								lcd_write_c(' ');
								lcd_move_cursor(LEFT);
							default:
								serial_send_s("NORMAL MODE!\n\r");
								break;
						}
					}
				}
				break;
			default:
				sleep();
				break;
		}
	}
	return 0;
}