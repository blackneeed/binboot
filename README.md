# (K)e(R)(N)e(L) (L)(O)(A)(D)er v1.0.1f

## Resources: 

- [Interrupt 0x10 AH=0x0E](https://fd.lod.bz/rbil/interrup/video/100e.html)
- [Interrupt 0x13 AH=0x02](https://fd.lod.bz/rbil/interrup/bios/1302.html#642)

## How to compile:
- Whenever you change the config (first lines of krnlload.asm) you'll have to re-compile
- To re-compile you will need nasm installed how to install it on debian based distros:    
    - root privileges required  
    ```sudo apt install make```  
    ```make debian-setup```
- How to install it on arch based distros:  
    - root privileges required     
    ```pacman -S make```  
    ```make arch-setup```  <br><br>
- To compile you need to run this command:  
    ```make compile```
### And just like that krnlload is compiled!

### How to use:
- Place your kernel in the same directory you have krnlload.bin
- Note that the kernel must be compiled to a binary
- To use krnlload you'll have to get your kernel binary name it however you want but you have to remember that in this example it is showed as `kernel.bin`  
```cat krnlload.bin kernel.bin > output.bin```   
This outputs a binary that is ready to use

### It's not working:
- If KRNLload is not working try these things:
- Go into the first lines of krnlload.asm and change KERNEL_START_SECTOR to 0x02 (Like this: `%define KERNEL_START_SECTOR 0x02`)  
- Go into the first lines of krnlload.asm and change SECTORS_TO_READ to a big number, the number depends on how big you're kernel is we assume that you know about sectors since you are making an operating system (Like this: `%define SECTORS_TO_READ 32`)

### Versioning scheme:
- #### Let's breakdown this:
    ```KRNLload v1.0.0d```
- KRNLload is the name of the bootloader
- v1.0.0 is the version
- d is the dev channel
- #### Now this:
    ```KRNLload v1.0.0f```
- KRNLload is the name of the bootloader
- v1.0.0 is the version
- f is the final release channel