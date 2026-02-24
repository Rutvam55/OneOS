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

    ; charger kernel
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x1000
    mov ah, 0x02
    mov al, 3        ; augmenter si kernel plus gros (lire 6 secteurs)
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80
    int 13h
    jc disk_error
    
    ; debug: afficher "OK" si kernel chargé
    mov ah, 0x0E
    mov al, 'O'
    int 10h
    mov al, 'K'
    int 10h
    lgdt [gdt_descriptor]
    
    ; activer bit PE (Protection Enable) dans CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; saut en code 32-bit
    jmp 0x08:start32

BITS 32
start32:
    ; initialiser stack
    mov esp, 0x90000
    
    ; charger segments de données
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Ne pas activer les interruptions ici — le kernel doit initialiser l'IDT/PIC
    ; sti
    
    ; TEST: afficher avant de sauter au kernel
    mov byte [0xB8000], 'K'
    mov byte [0xB8001], 0x0F
    mov byte [0xB8002], 'E'
    mov byte [0xB8003], 0x0F
    
    ; sauter au kernel à l'adresse 0x1000 où est _start
    jmp 0x08:0x1000

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
    mov al, 'D'
    int 10h
    mov al, 'i'
    int 10h
    mov al, 's'
    int 10h
    mov al, 'k'
    int 10h
    mov al, '_'
    int 10h
    mov al, 'E'
    int 10h
    mov al, 'r'
    int 10h
    mov al, 'r'
    int 10h
    mov al, 'o'
    int 10h
    mov al, 'r'
    int 10h
    jmp $

; --- Data ---
msg db "Loading FOS kernel v0.1...", 0
; boot drive sauvegardé à l'adresse 0x7C00 + 510
BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xAA55
