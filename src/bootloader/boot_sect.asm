[org 0x7C00] ;boot sector location
    BITS 16

; set up stack
mov bp, 0x8000
mov sp, bp ; empty stack

start:

    mov bx, LAUNCHTEXT
    call print
    call newline

    cli
    hlt

%include "src/bootloader/include/boot_sect_printstr.asm"

LAUNCHTEXT:
    db 'Welcome to CBOS', 0x0 ; end with null byte

times 510-($-$$) db 0
dw 0xaa55