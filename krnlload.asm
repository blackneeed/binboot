; KRNLload v1.0.1d

[org 0x7c00]

%define EndOfLine 0x0A, 0x0D
%define SectorsToRead 4
%define LoadKernelTo 0x7e00
%define KernelStartSector 0x02

main:
	mov bp, 0x7c00
	mov sp, bp

	mov [BootDisk], dl ; In dl by defualt bios should set the drive number
	call ClearScreen
	mov bx, NameString
	call PutS
	call ReadDisk

	jmp LoadKernelTo

hcf:
	cli
	.halt:
	hlt
	jmp .halt


ClearScreen:
	pusha
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	popa
	ret

PutS:
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

ReadDisk:
	mov ah, 0x02
	mov al, SectorsToRead
	mov ch, 0x00
	mov dh, 0x00
	mov cl, KernelStartSector
	mov dl, [BootDisk]
	mov bx, LoadKernelTo
	int 0x13
	jc .ReadDiskFail
	ret

.ReadDiskFail:
	mov bx, DiskFailString
	call PutS
	jmp hcf

BootDisk: db 0
NameString: db "Kernel loader v1.0.0d", EndOfLine, 0
DiskFailString: db "Could not load kernel!", EndOfLine, 0

times 510-($-$$) db 0
dw 0xaa55