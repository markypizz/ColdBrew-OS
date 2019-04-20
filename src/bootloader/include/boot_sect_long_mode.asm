[bits 16]

enter_long_mode:

; check_for_cpuid_support:
;     ; save + store eflags
;     pushfd
;     pushfd

;     ; invert ID bit
;     xor dword [esp],0x00200000

;     ; load stored EFLAGS (with inverted ID bit), restore
;     popfd
;     pushfd

;     ; eax has modified EFLAGS now
;     pop eax
;     xor eax,[esp]

;     ; back to original EEFLAGS
;     popfd
;     and eax,0x00200000

;     cmp eax, 0
;     jne check_for_long_mode_support

;     mov bx, 0x36
;     int 0x10

;     ; else, can't get CPUID instruction. Can't be sure of long mode support
;     ;mov bx, CPUID_NOT_SUPPORTED
;     ;call print_text
;     ;call newline
    
;     ; halt, error
;     cli
;     hlt

; check_for_long_mode_support:
;     mov eax, 0x80000000
;     cpuid
;     cmp eax, 0x80000001 ; check extended function definition available
    
;     jb long_mode_not_supported
    
;     mov eax, 0x80000001
;     cpuid
;     test edx, 1 << 29 ; check long mode bit
;     jz long_mode_not_supported
;     jmp setup_paging

; long_mode_not_supported:
;     ;mov bx, LONG_MODE_NOT_SUPPORTED
;     ;call print_text
;     ;call newline
    
;     ; error, just stall
    
;     cli
;     hlt

setup_paging:

    mov eax, cr0                                   ; Set the A-register to control register 0.
    and eax, 01111111111111111111111111111111b     ; Clear the PG-bit, which is bit 31.
    mov cr0, eax                                   ; Set control register 0 to the A-register.
    ; clear tables
    mov edi, 0x1000
    mov cr3, edi 
    xor eax, eax
    mov ecx, 4096,
    rep stosd ; clear memory
    mov edi, cr3 ; destination index to CR3

    ; Each table is 0x1000 in size. Use the unused early part
    ; of the address space
    ; PML4T --> 0x1000
    ; PDPT --> 0x2000
    ; PDT --> 0x3000
    ; PT --> 0x4000

    ; 0x?001 and 0x?002 are status bits
    mov dword [edi], 0x2003
    add edi, 0x1000
    mov dword [edi], 0x3003
    add edi, 0x1000
    mov dword [edi], 0x4003
    add edi, 0x1000

    mov ebx, 0x00000003
    mov ecx, 512

set_entry:
    mov dword [edi], ebx
    add ebx, 0x1000
    add edi, 8
    loop set_entry

    ; now enable PAE-paging
    mov eax, cr4
    or eax, 1 << 5 ; PAE bit is bit 6
    mov cr4, eax

enable_long_mode:
    mov edi, 0x9000 ; after stack -- DOES THIS WORK?
    ; drop right into enable long_mode
    push di
    mov ecx, 0x1000
    xor eax, eax
    cld
    rep stosd
    pop di

switch_from_real_mode:
    mov ecx, 0xC0000080 ; EFER MSR
    rdmsr ; model specific register
    or eax, 1 << 8 ; long mode bit - bit 9
    wrmsr ; write back

    ; enable paging & protected mode
    mov eax, cr0
    or eax, 1 << 31 | 1 << 0 ; PG bit 31, PM bit 0
    
    ;
    ;
    ; FAILING HERE
    ;
    ;
    mov cr0, eax ; failing here
    ;
    ;
    ;
    ;
    
    ; print OK to screen
    ;mov dword [0xb8000], 0x2f4b2f4f

GDT64:                           ; Global Descriptor Table (64-bit).
    .Null: equ $ - GDT64         ; The null descriptor.
    dw 0xFFFF                    ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 0                         ; Access.
    db 1                         ; Granularity.
    db 0                         ; Base (high).
    .Code: equ $ - GDT64         ; The code descriptor.
    dw 0                         ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 10011010b                 ; Access (exec/read).
    db 10101111b                 ; Granularity, 64 bits flag, limit19:16.
    db 0                         ; Base (high).
    .Data: equ $ - GDT64         ; The data descriptor.
    dw 0                         ; Limit (low).
    dw 0                         ; Base (low).
    db 0                         ; Base (middle)
    db 10010010b                 ; Access (read/write).
    db 00000000b                 ; Granularity.
    db 0                         ; Base (high).
    .Pointer:                    ; The GDT-pointer.
    dw $ - GDT64 - 1             ; Limit.
    dq GDT64                     ; Base.

    lgdt [GDT64.Pointer] ; load GDT
    jmp GDT64.Code:long_mode

debug_exit:
    ;;;
    mov al, 0x37
    mov ah, 0x0E
    int 0x10

    cli
    hlt
    ;;;;
[bits 64]
long_mode:
    call LONG_MODE_MAIN
;CPUID_NOT_SUPPORTED: db 'ERROR: Unable to use CPUID instruction to check for Long Mode Support', 0
;LONG_MODE_NOT_SUPPORTED: db 'ERROR: Long Mode is unsupported on this machine', 0