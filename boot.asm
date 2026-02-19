BITS 16
ORG 0x7C00

start:
    ; désactiver interruptions
    cli

    ; sauvegarde disque
    mov [BOOT_DRIVE], dl

    ; effacer écran
    mov ax, 0x0003
    int 10h

    ; afficher message
    mov si, msg
    call print_string    
    ; afficher caractère de confirmation (-)
    mov ah, 0x0E
    mov al, '-'
    int 10h
    ; charger kernel
    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 16       ; charger 16 secteurs (8 KB)
    mov ch, 0
    mov cl, 1        ; commencer au secteur 1 (pas 2!)
    mov dh, 0
    mov dl, [BOOT_DRIVE]
    int 13h
    jc disk_error
    
    ; afficher "K" pour confirmer le chargement
    mov ah, 0x0E
    mov al, 'K'
    int 10h

    ; charger GDT et passer en mode protégé
    lgdt [gdt_descriptor]
    
    ; activer bit PE (Protection Enable) dans CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; saut en code 32-bit
    jmp 0x08:start32

BITS 32
start32:
    ; initialiser stack en premier
    mov esp, 0x90000
    
    ; charger segments de données avec les bons indices GDT
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; réactiver interruptions
    sti
    
    ; sauter au kernel à l'adresse 0x10000 (dans le segment de code)
    ; Utiliser un appel indirect pour être sûr
    mov eax, 0x10000
    jmp eax

BITS 16
; --- GDT ---
gdt_start:
    ; entrée NULL
    dq 0x0000000000000000
    
    ; code segment (0x08)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00
    
    ; data segment (0x10)
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

; --- Fonctions ---
print_string:
    lodsb
    cmp al, 0
    je done
    mov ah, 0x0E
    int 10h
    jmp print_string
done:
    ret

disk_error:
    mov ah, 0x0E
    mov al, 'X'
    int 10h
    jmp $

; --- Data ---
msg db "===============", 0
BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xAA55
