    BITS 16

start:
    mov ah, 0x0E
    mov al, 'C'
    int 0x10
    mov al, 'B'
    int 0x10
    mov al, 'O'
    int 0x10
    mov al, 'S'
    int 0x10

    cli
    hlt

times 510-($-$$) db 0
dw 0xaa55