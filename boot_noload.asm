BITS 16
ORG 0x7C00

start:
    cli
    
    ; Passer directement en mode protégé
    ; sans charger depuis le disque
    
    ; Initialiser les registres
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; effacer écran et positionner curseur à (0, 0)
    mov ax, 0x0003
    int 10h
    mov ax, 0x0200
    mov bx, 0x0000
    int 10h

    ; Afficher "BOOT:" en vidéo mémoire
    mov ax, 0xB800
    mov es, ax
    mov byte [es:0], 'S'
    mov byte [es:1], 0x0F
    mov byte [es:2], 'T'
    mov byte [es:3], 0x0F
    mov byte [es:4], 'A'
    mov byte [es:5], 0x0F
    mov byte [es:6], 'R'
    mov byte [es:7], 0x0F
    mov byte [es:8], 'T'
    mov byte [es:9], 0x0F
    mov byte [es:10], 'I'
    mov byte [es:11], 0x0F
    mov byte [es:12], 'N'
    mov byte [es:13], 0x0F
    mov byte [es:14], 'G'
    mov byte [es:15], 0x0F
    
    ; Charger GDT et passer en mode protégé
    lgdt [gdt_descriptor]
    
    ; Activer PE dans CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Saut en mode 32-bit avec seg code 0x08
    jmp 0x08:protected_mode

BITS 32
protected_mode:
    ; Charger descripteurs de données
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Initialiser stack
    mov esp, 0x90000
    
    ; Activer interruptions
    sti
    
    ; Sauter directement au kernel à 0x10000
    ; Le kernel est lié au même endroit dans l'image disque
    mov eax, 0x10000
    jmp eax
    
    ; Le kernel commence ici (à 0x10000 dans la mémoire physique)

BITS 16
; --- GDT ---
gdt_start:
    ; Null entry
    dq 0x0000000000000000
    
    ; Code segment (0x08)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00
    
    ; Data segment (0x10)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Boot signature
times 510-($-$$) db 0
dw 0xAA55
