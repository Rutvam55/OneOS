BITS 32

extern kernel_main

global _start

_start:
    ; appeler kernel_main en 32-bit pur
    call kernel_main
    
    ; ne jamais retourner
    cli
    hlt
    jmp $
 
; Prevent linker warning about executable stack
section .note.GNU-stack

