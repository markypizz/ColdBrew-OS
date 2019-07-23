[org 0x7c00]
[BITS 16]

start:
	cli ; clear interrupts
	lgdt [gdt_descriptor] ; load GDT

	mov eax, cr0
	or eax,0x1
	mov cr0, eax ; kick off transition
	jmp CODE_SEG:main_protected ; long jump to proected mode code

gdt_start:
	dq 0x0          ; null bytes
gdt_code:
	dw 0xFFFF       ; segment limit
	dw 0x0          ; segment base addr
	db 0x0          ; segment base addr
	db 10011010b    ; Readable segment, code segment, present flag
	db 11001111b    ; Segment limit, 32 bit size, 4 GB
	db 0x0          ; segment base addr
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start
	dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[BITS 32]
main_protected:
	mov ax, DATA_SEG ; set up regs
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov esi, hello ; string
	mov ebx, 0xb8000 ; video memory
    mov esp, 0x9000 ; stack pointer

printloop:
	lodsb
	or al, al ; check for terminating null byte
	jz halt ; done printing
	or eax, 0x0200 ; text color
	mov word [ebx], ax
	add ebx, 2
	jmp printloop
halt:
	cli
	hlt
hello: db "Welcome to CBOS", 0

; boot sector signature
times 510-($-$$) db 0
dw 0xaa55
