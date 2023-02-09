#!/bin/sh
for i in tests/*.c
do
	b=$(basename $i .c)
	echo  $b":"
	cc85 -m8085 -c tests/$b.c
	ld85 -b -C0 testcrt0.o tests/$b.o -o tests/$b /opt/cc85/lib/lib8085.a -m tests/$b.map
	./emu85 tests/$b tests/$b.map
done