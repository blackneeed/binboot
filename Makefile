arch-setup:
	pacman -Sy nasm --noconfirm

debian-setup:
	apt update
	apt install nasm -y

compile:
	nasm -f bin krnlload.asm -o krnlload.bin