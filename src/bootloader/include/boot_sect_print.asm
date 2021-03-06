[bits 16]
print_text:
    pusha ; push all
    
    printloop:
        mov al, [bx]
        cmp al, 0 ; end of string
        je exitprint

        mov ah, 0x0E
        int 0x10

        inc bx
        jmp printloop

    exitprint:
    popa ; pop all
    ret

print_digit:
    pusha
    
    mov al, bl
    add al, 0x30 ; convert to ASCII digit

    mov ah, 0x0E
    int 0x10

    popa
    ret

newline:
    pusha
    
    mov ah, 0x0e
    mov al, 0x0a ; NL
    int 0x10
    mov al, 0x0d ; CR
    int 0x10
    
    popa
    ret