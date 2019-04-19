[org 0x7C00] ;boot sector location
KERNEL_ADDRESS_OFFSET equ 0x1000
    BITS 16

; hold onto boot drive value
mov [BOOT_DRIVE], dl 

; set up stack
mov bp, 0x9000
mov sp, bp ; empty stack

start:
    mov bx, LAUNCH_TEXT
    call print_text
    call newline

    ; Start loading of DISK
    mov bx, DISK_LOAD_TEXT
    call print_text
    call newline

    mov bx, 0x9000
    mov dh, 2 ; 2 sectors
    call load_disk

    mov bx, DISK_LOAD_SUCCESS
    call print_text
    call newline

    ; switch to LONG mode
    call enter_long_mode

    ; should never ocurr
    cli
    hlt

%include "src/bootloader/include/boot_sect_print.asm"
%include "src/bootloader/include/boot_sect_disk_load.asm"
%include "src/bootloader/include/boot_sect_long_mode.asm"

[bits 64]
LONG_MODE_ENTER:
    ; print a message here?
    call KERNEL_ADDRESS_OFFSET

    ; if kernel ever gave back control, though should never happen
    cli
    hlt

BOOT_DRIVE: db 0
LAUNCH_TEXT: db 'Welcome to ColdBrew OS', 0 ; c-style end with null byte
DISK_LOAD_TEXT: db 'Starting load from DISK...', 0
DISK_LOAD_SUCCESS: db 'Loaded DISK successfully.',0

times 510-($-$$) db 0
dw 0xaa55 ; bootsector indicator

; sector 2
times 256 dw 0xaabb

; sector 3
times 256 dw 0xccdd