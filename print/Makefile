all: launch

launch: link
	valgrind ./print

link: comp
	ld -s -o print print.o

comp:
	nasm -w+all -f elf64 -g -F dwarf  -l print.lst print.s

clean:
	rm print.o print.lst print

edb: launch
	edb --run ./print