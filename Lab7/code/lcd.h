#ifndef LCD_H
#define LCD_H

#include <avr/io.h>
#include "ebi_driver.h"
#include "helpers.h"

#define  LCD_CMD		0x471000
#define  LCD_DATA		0x471001

#define FALSE 0
#define TRUE 1
typedef int bool;

#define LEFT  0
#define RIGHT 1
#define DOWN  2
#define UP    3
typedef int dir;

static uint8_t cursor_pos;
static bool lcd_on = FALSE;

void init_lcd(void);
void lcd_cmd(short);
void lcd_clear(void);
bool lcd_busy(void);
void wait_lcd(void);
void lcd_write_c(char);
void lcd_write_s(char*);
void lcd_reset_cursor(void);
void lcd_next_line(void);
int lcd_hpos(void);
int lcd_vpos(void);
void set_pos(int h, int v);
void toggle_lcd(void);
void lcd_move_cursor(dir);

void init_lcd(void) {
	// Ensure it has been at least 40ms since start. See data sheet.
	delay_ms(40);
	// Two lines
	__far_mem_write(LCD_CMD, 0b111100);
	delay_ms(40);
	__far_mem_write(LCD_CMD, 0b111100);
	delay_ms(40);
	// Now, we can safely poll the BF Flag. See data sheet.
	lcd_cmd(0b1111); // Set Cursor and Display on
	wait_lcd();
	lcd_on = TRUE;
	lcd_cmd(0b110); // Cursor increments right and shifts
	lcd_clear();
}

void lcd_write_c(char c) {
	if (c == '\n') {
		lcd_next_line();
		return;
	}
	wait_lcd();
	__far_mem_write(LCD_DATA, (int)c);
	++cursor_pos;
	if (cursor_pos == 16) {
		cursor_pos = 40;
		lcd_cmd(0x80 | cursor_pos);
	} else if (cursor_pos == 56) {
		cursor_pos = 0;
		lcd_cmd(0x80);
	}
}

void lcd_write_s(char* string) {
	while (*string != '\0') {
		lcd_write_c(*(string++));
	}
}

void lcd_cmd(short cmd) {
	wait_lcd();
	__far_mem_write(LCD_CMD, cmd);
}

void lcd_clear(void) {
	lcd_cmd(0b1);
	cursor_pos = 0;
}

bool lcd_busy(void) {
	delay_ms(5);
	return FALSE;
	int x = __far_mem_read(LCD_CMD);
	return (x & 0x80) != 0;
}

void wait_lcd(void) {
	do {
	} while(lcd_busy() != FALSE);
}

void lcd_reset_cursor(void) {
	lcd_cmd(0b10);
}

void lcd_next_line(void) {
	if (cursor_pos < 40) {
		cursor_pos = 40;
		lcd_cmd(0x80 | cursor_pos);
	} else {
		cursor_pos = 0;
		lcd_cmd(0x80);
	}
}

int lcd_hpos(void) {
	if (cursor_pos < 16) {
		return cursor_pos;
	} else {
		return cursor_pos - 40;
	}
}

int lcd_vpos(void) {
	if (cursor_pos < 16) {
		return 0;	
	} else {
		return 1;
	}
}

void set_pos(int h, int v) {
	if (v == 0) {
		lcd_cmd(0x80 | h);
		cursor_pos = h;
	} else {
		if (h - lcd_hpos() == 1) {
			lcd_cmd(0x14);
			cursor_pos += 1;
		} else if (h - lcd_hpos() == -1) {
			lcd_cmd(0x10);
			cursor_pos -= 1;
		} else {
			cursor_pos = 40;
			lcd_cmd(0x80 | 40);
			for (int i = 0; i < h; ++i) {
				lcd_move_cursor(RIGHT);	
			}
		}
	}
}

void toggle_lcd(void) {
	lcd_on ^= TRUE;
	lcd_cmd(0b1111 ^ (lcd_on << 2));
}

void lcd_move_cursor(dir d) {
	switch (d) {
		case LEFT:
			if (lcd_vpos() == 1 && lcd_hpos() == 0) {
				set_pos(15, 0);
			} else if (lcd_hpos() != 0) {
				set_pos(lcd_hpos() - 1, lcd_vpos());
			}
			break;
		case RIGHT:
			if (lcd_vpos() == 0 && lcd_hpos() == 15) {
				set_pos(0, 1);
			} else if (lcd_hpos() != 15) {
				set_pos(lcd_hpos() + 1, lcd_vpos());
			}
			break;
		case UP:
			if (lcd_vpos() == 1) {
				set_pos(lcd_hpos(), 0);
			}
			break;
		case DOWN:
			if (lcd_vpos() == 0) {
				set_pos(lcd_hpos(), 1);
			}
			break;
	}
}

#endif
