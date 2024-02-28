; KrnlLoad v1.0.1f

[org 0x7c00]
[bits 16]

%define SectorsToRead 4
%define LoadKernelTo 0x7e00
%define KernelStartSector 0x02
%define EndOfLine 0x0A, 0x0D

%macro SetDataSegments 1
; Set data segments
mov ds, %1
mov es, %1
mov fs, %1
mov gs, %1
mov ss, %1
%endmacro

%macro PushAll 0
push ax ; Push AX
push bx ; Push BX
push cx ; Push CX
push dx ; Push DX
%endmacro

%macro PopAll 0
pop dx ; Pop DX
pop cx ; Pop CX
pop bx ; Pop BX
pop ax ; Pop AX
%endmacro

; Entry
main:
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

	jmp LoadKernelTo ; Pass control to the kernel

; Halt and catch fire
hcf:
	cli ; Clear interrupts
	.halt: ; Halt in a infinite loop
	hlt ; Halt
	jmp .halt ; Jump back to the start of the loop

; Clear Screen Function
ClearScreen:
	PushAll ; Push all macro
	mov ah, 0x00 ; Change the bios interrupt to 0x00
	mov al, 0x03 ; Set the video mode to 0x03
	int 0x10 ; Call video interrupt
	PopAll ; Pop all macro
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
	pop ax ; Pop AX
	pop bx ; Pop BX
	ret ; Return

; Read disk function
ReadDisk:
	mov ah, 0x02 ; Set bios interrupt to 0x02
	mov al, SectorsToRead ; Set sector count to the config variable SectorsToRead
	mov ch, 0x00 ; Set the cylinder to 0
	mov dh, 0x00 ; Set the head to 0
	mov cl, KernelStartSector ; Set the sector to the config variable KernelStartSector
	mov dl, [BootDisk] ; Move the boot disk into DL
	mov bx, LoadKernelTo ; Tell BIOS to load the kernel into the config variable LoadKernelTo
	int 0x13 ; Call disk services interrupt
	jc .ReadDiskFail ; If failed jump to read disk fail
	ret ; Return

.ReadDiskFail: ; Define read disk fail
	mov bx, DiskFailString ; Move the DiskFailString into BX
	call PutS ; Print
	jmp hcf ; Halt and catch fire

BootDisk: db 0 ; Changed later
NameString: db "Kernel loader v1.0.1f", EndOfLine, 0 ; The name and version
DiskFailString: db "Could not load kernel!", EndOfLine, 0 ; String when we cannot read the kernel

times 510-($-$$) db 0
dw 0xaa55