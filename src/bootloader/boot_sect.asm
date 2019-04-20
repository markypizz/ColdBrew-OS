[org 0x7C00] ;boot sector location
KERNEL_ADDRESS_OFFSET equ 0x1000

[bits 16]

; hold onto boot drive value
mov [BOOT_DRIVE], dl 

; set up stack
mov bp, 0x9000
mov sp, bp ; empty stack

start:
    ;mov bx, LAUNCH_TEXT
    ;call print_text
    ;call newline

    ; Start loading of DISK
    ;mov bx, DISK_LOAD_TEXT
    ;;call print_text
    ;call newline

    mov bx, 0x9000
    mov dh, 2 ; 2 sectors
    call load_disk

    ;mov bx, DISK_LOAD_SUCCESS
    ;call print_text
    ;call newline

    ; switch to LONG mode
    jmp enter_long_mode



;%include "src/bootloader/include/boot_sect_print.asm"
%include "src/bootloader/include/boot_sect_disk_load.asm"
%include "src/bootloader/include/boot_sect_long_mode.asm"

[bits 64]
LONG_MODE_MAIN:

    cli                           ; Clear the interrupt flag.
    mov ax, GDT64.Data            ; Set the A-register to the data descriptor.
    mov ds, ax                    ; Set the data segment to the A-register.
    mov es, ax                    ; Set the extra segment to the A-register.
    mov fs, ax                    ; Set the F-segment to the A-register.
    mov gs, ax                    ; Set the G-segment to the A-register.
    mov ss, ax                    ; Set the stack segment to the A-register.
    mov edi, 0xB8000              ; Set the destination index to 0xB8000.
    mov rax, 0x1F201F201F201F20   ; Set the A-register to 0x1F201F201F201F20.
    mov ecx, 500                  ; Set the C-register to 500.
    rep stosq                     ; Clear the screen.

    mov rax, 0x2f592f412f4b2f4f
    mov qword [0xb8000], rax
    hlt
    
BOOT_DRIVE: db 0
;LAUNCH_TEXT: db 'Welcome to ColdBrew OS', 0 ; c-style end with null byte
;DISK_LOAD_TEXT: db 'Starting load from DISK...', 0
;DISK_LOAD_SUCCESS: db 'Loaded DISK successfully.',0
LONG_MODE_STR: db 'Long Mode Enabled.',0

times 510-($-$$) db 0
dw 0xaa55 ; bootsector indicator

; sector 2
times 256 dw 0xaabb

; sector 3
times 256 dw 0xccdd