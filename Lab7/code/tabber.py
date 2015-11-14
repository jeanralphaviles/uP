#!/usr/bin/python3
import sys

for line in sys.stdin:
    line = line.split("|")
    octave = int(line[0])
    count = 0;
    last_c = 'a'
    for c in line[1]:
        if c is '>':
            count += 1
        elif c is '-':
            if last_c is not '-':
                if count > 0:
                    if last_c.isupper():
                        print("  {%s%sS,\t%s}," % (last_c, octave + 2, count))
                    else:
                        print("  {%s%s,\t%s}," % (last_c.upper(), octave + 2, count))
                last_c = c
                count = 0
            count += 1
        else:
            if count > 0:
                if last_c.isupper():
                    print("  {%s%sS,\t%s}," % (last_c, octave + 2, count))
                elif last_c is '-':
                    print("  {0,\t%s}," % (count))
                else:
                    print("  {%s%s,\t%s}," % (last_c.upper(), octave + 2, count))
            last_c = c
            count = 1

