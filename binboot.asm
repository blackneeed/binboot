; binboot v1.0.2f

[org 0x7c00]
[bits 16]

%define sectors_to_read 4
%define load_kernel_to_seg 0
%define load_kernel_to_off 0x7e00
%define kernel_start_sector 0x02

main:
	jmp 0:.after_cs
.after_cs:
	mov bp, 0x7c00
	mov sp, bp

	mov ax, 0
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov [boot_disk], dl
	call clear_screen
	mov bx, name_string
	call print_string
	call read_disk

	jmp load_kernel_to_seg:load_kernel_to_off

hcf:
	cli
	.halt:
	hlt
	jmp .halt

clear_screen:
	pusha
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	popa
	ret

print_string:
	push ax
	push bx
	.Loop:
	mov al, [bx]
	test al, al
	jz .Ret
	mov ah, 0x0e
	int 0x10
	inc bx
	jmp .Loop
	.Ret:
	pop bx
	pop ax
	ret

read_disk:
	cli
	push dx
	mov ah, 0x02
	mov al, sectors_to_read
	mov ch, 0x00
	mov dh, 0x00
	mov cl, kernel_start_sector
	mov dl, [boot_disk]
	push ax
	mov ax, load_kernel_to_seg
	mov es, ax
	pop ax
	mov bx, load_kernel_to_off
	int 0x13
	pop dx
	jc .read_disk_fail
	ret

.read_disk_fail:
	mov bx, disk_fail_string
	call print_string
	jmp hcf

boot_disk: db 0
name_string: db "binboot v1.0.2f", 0xD, 0xA, 0
disk_fail_string: db "Could not load kernel!", 0xD, 0xA, 0

times 510-($-$$) db 0
dw 0xaa55