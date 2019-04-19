[bits 16]

PAGE_PRESENT equ (1 << 0)
PAGE_WRITE   equ (1 << 1)

CODE_SEG     equ 0x0008
DATA_SEG     equ 0x0010

enter_long_mode:

check_for_cpuid_support:
    pusha
    ; save + store eflags
    pushfd
    pushfd

    ; invert ID bit
    xor dword [esp],0x00200000

    ; load stored EFLAGS (with inverted ID bit), restore
    popfd
    pushfd

    ; eax has modified EFLAGS now
    pop eax
    xor eax,[esp]

    ; back to original EEFLAGS
    popfd
    and eax,0x00200000

    cmp eax, 0
    jne check_for_long_mode_support

    ; else, can't get CPUID instruction. Can't be sure of long mode support
    ;mov bx, CPUID_NOT_SUPPORTED
    ;call print_text
    ;call newline
    
    ; halt, error
    cli
    hlt

check_for_long_mode_support:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001 ; check extended function definition available
    
    jb long_mode_not_supported
    
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29 ; check long mode bit
    jz long_mode_not_supported

enable_long_mode:
    mov edi, 0x9000 ; after stack -- DOES THIS WORK?
    ; drop right into enable long_mode
    push di
    mov ecx, 0x1000
    xor eax, eax
    cld
    rep stosd
    pop di



    ; todo




    
long_mode_not_supported:
    mov bx, LONG_MODE_NOT_SUPPORTED
    call print_text
    call newline
    
    ; error, just stall
    cli
    hlt
    popa
    ret
    
;CPUID_NOT_SUPPORTED: db 'ERROR: Unable to use CPUID instruction to check for Long Mode Support', 0
LONG_MODE_NOT_SUPPORTED: db 'ERROR: Long Mode is unsupported on this machine', 0