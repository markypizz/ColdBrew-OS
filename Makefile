#all:




boot_sect.bin:
	nasm -f bin -o ./bin/boot.bin ./src/bootloader/boot_sect.asm