/*
* Lab7_PartB.c
* Lab7 Keypad Part
* Created: 11/11/2015 2:26:05 PM
* Author: Jean-Ralph Aviles
*/

#include <avr/io.h>

#include "helpers.h"
#include "keypad.h"
#include "lcd.h"
#include "speaker.h"

void game_of_thrones(void);
void pokemon(void);

int main(void) {
  init();
  init_speaker();
  init_keypad();
  init_lcd();
  sleep_mode_set(SLEEP_MODE_IDLE);
  enable_sleep();
  intmask_set(0x04);
  enable_int();
  char temp[10];
  while(1) {
    sleep();
    lcd_clear();
    switch (last_key) {
      case '1':
        lcd_write_s("C6\n1046.50 Hz");
        play_note(C6, 250);
        break;
      case '2':
        lcd_write_s("C6S\n1108.73 Hz");
        play_note(C6S, 250);
        break;
      case '3':
        lcd_write_s("D6\n1174.66 Hz");
        play_note(D6, 250);
        break;
      case '4':
        lcd_write_s("D6S\n1244.51 Hz");
        play_note(D6S, 250);
        break;
      case '5':
        lcd_write_s("E6\n1318.51 Hz");
        play_note(E6, 250);
        break;
      case '6':
        lcd_write_s("F6\n1396.91 Hz");
        play_note(F6, 250);
        break;
      case '7':
        lcd_write_s("F6S\n1479.98 Hz");
        play_note(F6S, 250);
        break;
      case '8':
        lcd_write_s("G6\n1567.98 Hz");
        play_note(G6, 250);
        break;
      case '9':
        lcd_write_s("G6S\n1661.22 Hz");
        play_note(G6S, 250);
        break;
      case '0':
        lcd_write_s("A6\n1760.00 Hz");
        play_note(A6, 250);
        break;
      case 'A':
        lcd_write_s("A6S\n1864.66 Hz");
        play_note(A6S, 250);
        break;
      case 'B':
        lcd_write_s("B6\n1975.53 Hz");
        play_note(B6, 250);
        break;
      case 'C':
        lcd_write_s("C7\n2093.00 Hz");
        play_note(C7, 250);
        break;
      case 'D':
        lcd_write_s("C7S\n2217.46 Hz");
        play_note(C7S, 250);
        break;
      case '*':
        lcd_write_s("Game of Thrones\nTheme Song");
        game_of_thrones();
        break;
			case '#':
        lcd_write_s("Pokemon Route #1");
        pokemon();
        break;
      default:
        write_led(10);
        break;
    }
  }
  return 0;
}


#define TEMPO		55
#define NNOTES  50

float GOT[NNOTES][2] = {
  {G6,	6},
  {C6,	6},
  {D6S,	3},
  {F6,	3},
  {G6,	6},
  {C6,	6},
  {D6S,	3},
  {F6,	3},
  {G6,	6},
  {C6,	6},
  {D6S,	3},
  {F6,	3},
  {G6,	6},
  {C6,	6},
  {E6,	3},
  {F6,	3},

  {G5,	18},
  {C5,	18},
  {D5S,	3},
  {F5,	3},
  {G5,	12},
  {C5,	12},
  {D5S,	3},
  {F5,	3},

	{D5, 72},

  {F6,	18},
  {A5S,	18},

  {D6,	3},
  {D6S,	3},
  {F6,	12},
  {A5S,	12},

  {D6S,	3},
  {D6,	3},
	{C6,  72},

  {G6,	18},
  {C6,	18},
  {D6S,	3},
  {F6,	3},
  {G6,	12},
  {C6,	12},
  {D6S,	3},
  {F6,	3},

	{D6,  72},

  {F6,	18},
	{A5S,	18},
  {D6,	9},
  {D6S,	9},
  {D6,	9},
	{A5S,	9},

	{C6,  72}
};

void game_of_thrones() {
	for (uint16_t i = 0; i < NNOTES; ++i) {
		play_note(GOT[i][0], GOT[i][1]*TEMPO);
	}
}

#define TEMPO_P		80
#define NNOTES_P  204

float POKE[NNOTES_P][2] = {
  {0,	2},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {G6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {E6,	1},
  {0,	2},
  {C6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {C6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {C6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {F6S,	1},
  {D6,	1},
  {F6S,	1},
  {0,	1},

  {0,	2},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {G6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {E6,	1},
  {0,	2},
  {C6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {G6,	1},
  {0,	1},
  {F6S,	1},
  {0,	1},
  {E6,	1},
  {0,	1},
  {D6,	1},
  {0,	1},
  {C6S,	1},
  {0,	1},
	{B5, 1},
  {0,	1},
  {C6S,	1},
  {0,	1},
  {B6,	1},
  {0,	1},
	{B5, 1},
  {0,	1},
  {C6S,	1},
  {0,	1},
	{B5, 1},
  {0,	1},
	{A5, 1},
  {0,	1},
  {C6S,	1},
  {0,	1},
  {D6,	1},
  {0,	1},

  {0,	2},
  {F6S,	1},
  {0,	2},
  {G6,	1},
  {0,	2},
  {A6,	1},
  {0,	2},
  {A6,	1},
  {0,	2},
  {F6S,	1},
  {0,	2},
  {D6,	1},
  {0,	2},
	{D7, 1},
  {0,	2},
	{C7, 1},
  {0,	2},
  {B6,	1},
  {0,	2},
	{C7, 1},
  {0,	2},
  {A6,	1},
  {0,	2},
  {F6S,	1},
  {0,	2},
  {D6,	1},
  {0,	2},
  {F6S,	1},
  {0,	2},
  {E6,	1},
	{0, 3},

  {0,	2},
  {F6S,	1},
  {0,	2},
  {G6,	1},
  {0,	2},
  {A6,	1},
  {0,	2},
  {A6,	1},
  {0,	2},
  {F6S,	1},
  {0,	2},
  {A6,	1},
  {0,	2},
	{D7, 1},
  {0,	2},
	{C7, 1},
  {0,	2},
  {B6,	1},
  {0,	2},
  {G6,	1},
  {0,	2},
  {A6,	1},

  {0,	2},
  {D7,	1},
  {0,	2},
  {C7S,	1},
  {0,	2},
  {E7,	1},
  {0,	2},
  {D7,	1},
  {0,	2}
};

void pokemon() { 
	for (uint16_t i = 0; i < NNOTES_P; ++i) {
		play_note(POKE[i][0], POKE[i][1]*TEMPO_P);
	}
}
