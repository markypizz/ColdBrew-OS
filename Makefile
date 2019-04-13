# iso
cbos.iso: cbos.img
	mkisofs -r -b cbos.img -o ./iso/cbos.iso ./img/

# img
cbos.img: boot_sect.bin
	dd if=/dev/zero of=./img/cbos.img bs=1024 count=1440
	dd if=./bin/boot_sect.bin of=./img/cbos.img seek=0 count=1 conv=notrunc

# Boot sector binary
boot_sect.bin:
	nasm -f bin -o ./bin/boot_sect.bin ./src/bootloader/boot_sect.asm

# Remove built files
clean:
	rm -rf ./img/* ./bin/* ./iso/*