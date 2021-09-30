printf: printf.asm
	yasm -g dwarf2 -f elf64 $< -l $@.lst
	ld $@.o -o $@
