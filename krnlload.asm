; KRNLload v1.0.0f

[org 0x7c00]

%define EOL 0x0A, 0x0D

%include "config.asm"

main:
	mov bp, 0x7c00
	mov sp, bp

	mov [BOOT_DRIVE], dl ; In dl by defualt bios should set the drive number
	mov bx, NAME_STRING
	call PUT_STRING
	call Read 

	jmp LOAD_KERNEL_TO

PUT_STRING:
	push ax
	push bx
	.Loop:
	cmp [bx], byte 0
	je .Ret
	mov ah, 0x0e
	mov al, [bx]
	int 0x10
	inc bx
	jmp .Loop
	.Ret:
	pop ax
	pop bx
	ret

Read:
	mov ah, 0x02
	mov al, SECTORS_TO_READ
	mov ch, 0x00
	mov dh, 0x00
	mov cl, KERNEL_START_SECTOR
	mov dl, [BOOT_DRIVE]
	mov bx, LOAD_KERNEL_TO
	int 0x13
	jc Fail
	ret

Fail:
	mov bx, FAIL_STRING
	call PUT_STRING
	cli
	.loop:
		hlt
		jmp .loop ; Sometimes something can happen so its best to be sure that it halts

BOOT_DRIVE: db 0
NAME_STRING: db "KRNLLOAD", 0x0A, 0x0D, 0
FAIL_STRING: db "Could not load kernel!", EOL, 0

times 510-($-$$) db 0
dw 0xaa55