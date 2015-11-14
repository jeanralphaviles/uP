/*
* Lab7_PartA.c
* Generates 1760Hz Tone on Speaker
* Created: 11/11/2015 2:06:40 PM
* Author: Jean-Ralph Aviles
*/

#include <avr/io.h>

#include "helpers.h"
#include "speaker.h"

int main(void) {
  init();
  init_speaker();
  set_frequency(1760);
  while(1) {
    /* Speaker is Enabled when Switch0
     * is True */
    if (read_switches() & 0x01) {
      enable_speaker();
    } else {
      disable_speaker();
    }
  }
  return 0;
}
