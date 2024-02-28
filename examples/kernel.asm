[bits 16]
[org 0x7e00]

section .text

start: jmp main

PUT_STRING:
	push ax
	push bx
	.Loop:
	mov al, [bx]
	cmp al, 0
	je .Ret
	mov ah, 0x0e
	int 0x10
	inc bx
	jmp .Loop
	.Ret:
	pop ax
	pop bx
	ret

main:

    mov bx, WELCOME_MSG
    call PUT_STRING

    cli
    hlt

section .data

WELCOME_MSG: db 'Welcome from kernel loaded by KRNLload!', 0x0A, 0x0D, 0

section .bss

times 2048-($-$$) db 0