all: launch

.PHONY: launch link comp asm_to_c clean edb

launch: link_asm
	valgrind ./print

link_asm: c_to_asm
	g++ -no-pie c_to_asm.o -o print

link_c: comp_asm asm_to_c
	g++ -no-pie print.o asm_to_c.o -o print

link: comp_asm
	ld -s print.o -o print

comp_asm:
	nasm -w+all -f elf64 -g -l print.lst print.s

asm_to_c: comp_asm
	g++ -Wall -c asm_to_c.c -o asm_to_c.o

c_to_asm:
	nasm -w+all -f elf64 -g -l c_to_asm.lst c_to_asm.s

clean:
	rm *.o print.lst print

rebuild: clean all

edb: launch
	edb --run ./print