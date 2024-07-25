[org 0x7e00]
[bits 16]
[cpu 8086]

_start:
    mov ah, 0x0e
    mov al, 'k'
    int 0x10
    mov al, 'r'
    int 0x10
    mov al, 'n'
    int 0x10
    mov al, 'l'
    int 0x10
    cli
    .halt:
    hlt
    jmp .halt

times 2048-($-$$) db 0