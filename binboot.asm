; KrnlLoad v1.0.1f

[org 0x7c00]
[bits 16]

%define SectorsToRead 4
%define LoadKernelToSeg 0
%define LoadKernelToOff 0x7e00
%define KernelStartSector 0x02
%define EndOfLine 0x0A, 0x0D

%macro SetDataSegments 1
; Set data segments
mov ax, %1
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
%endmacro

; Entry
main:
	jmp 0:.after_cs
.after_cs:
	; Setup the stack
	mov bp, 0x7c00
	mov sp, bp

	; Clear all segment registers
	SetDataSegments 0

	; Set the BootDisk variable for later
	mov [BootDisk], dl ; BIOS automatically sets DL to be the boot drive number
	call ClearScreen ; Clear the screen
	mov bx, NameString ; Move the NameString label into BX
	call PutS ; Print BX
	call ReadDisk ; Read the disk

	jmp LoadKernelToSeg:LoadKernelToOff ; Pass control to the kernel

; Halt and catch fire
hcf:
	cli ; Clear interrupts
	.halt: ; Halt in a infinite loop
	hlt ; Halt
	jmp .halt ; Jump back to the start of the loop

; Clear Screen Function
ClearScreen:
	pusha ; Push all registers
	mov ah, 0x00 ; Change the bios interrupt to 0x00
	mov al, 0x03 ; Set the video mode to 0x03
	int 0x10 ; Call video interrupt
	popa ; Pop all registers
	ret ; Return

; Print string function
PutS:
	push ax ; Push AX
	push bx ; Push BX
	.Loop:
	mov al, [bx] ; Move the byte from BX to AL
	test al, al ; Compare al
	jz .Ret ; Jump if zero into return
	mov ah, 0x0e ; Set the bios interrupt to 0x0e
	int 0x10 ; Call video interurpt
	inc bx ; Increment the BX data pointer
	jmp .Loop ; Jump back into the start of the loop
	.Ret: ; Define return
	pop bx ; Pop BX
	pop ax ; Pop AX
	ret ; Return

; Read disk function
ReadDisk:
	cli
	push dx
	mov ah, 0x02 ; Set bios interrupt to 0x02
	mov al, SectorsToRead ; Set sector count to the config variable SectorsToRead
	mov ch, 0x00 ; Set the cylinder to 0
	mov dh, 0x00 ; Set the head to 0
	mov cl, KernelStartSector ; Set the sector to the config variable KernelStartSector
	mov dl, [BootDisk] ; Move the boot disk into DL
	push ax
	mov ax, LoadKernelToSeg
	mov es, ax
	pop ax
	mov bx, LoadKernelToOff ; Tell BIOS to load the kernel into the config variable LoadKernelTo
	int 0x13 ; Call disk services interrupt
	pop dx
	jc .ReadDiskFail ; If failed jump to read disk fail
	ret ; Return

.ReadDiskFail: ; Define read disk fail
	mov bx, DiskFailString ; Move the DiskFailString into BX
	call PutS ; Print
	jmp hcf ; Halt and catch fire

BootDisk: db 0 ; Changed later
NameString: db "binboot v1.0.2d", EndOfLine, 0 ; The name and version
DiskFailString: db "Could not load kernel!", EndOfLine, 0 ; String when we cannot read the kernel

times 510-($-$$) db 0
dw 0xaa55