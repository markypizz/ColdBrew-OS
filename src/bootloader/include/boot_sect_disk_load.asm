load_disk:
    pusha
    push dx ; store number of sectors from caller


    ; TODO, constant these guys?
    mov ah, 0x02 ; read
    mov al, dh   ; number of sectors
    mov cl, 0x02 ; sector (first available is sector 2)
    mov ch, 0x00 ; cylinder (first)
    ; dl set by BIOS (current drive)
    mov dh, 0x00
    
    int 0x13
    jc disk_error

    pop dx
    cmp al, dh ; make sure sectors are equal
    jne sectors_not_equal
    popa
    ret

disk_error:
    mov bx, ERROR_DISK
    call print_text
    call newline

    mov dh, ah
    ; TODO - implement function to print the error code

    jmp disk_error_loop

sectors_not_equal:

    mov bx, SECTORS_NE_ERROR_1
    call print_text

    mov bl, dh ; expected
    call print_digit

    mov bx, SECTORS_NE_ERROR_2
    call print_text

    mov bl, al ; actual
    call print_digit

    jmp disk_error_loop


disk_error_loop:
    cli ; TODO
    hlt

ERROR_DISK: db 'Error while reading disk', 0
SECTORS_NE_ERROR_1: db 'Disk load error: Expected read of ', 0
SECTORS_NE_ERROR_2: db ' sectors. Actual read: ', 0