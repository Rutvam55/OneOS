// Affichage écran (mémoire vidéo)
void put_char(int pos, char c, char color, char* video) {
    video[pos * 2] = c;
    video[pos * 2 + 1] = color;
}

void line(char* str, char color, char* video, int line_number) {
    int start_pos = line_number * 80;
    for (int i = 0; str[i] != '\0'; i++) {
        put_char(start_pos + i, str[i], color, video);
    }
}

void clear_screen(char* video) {
    for (int i = 0; i < 80 * 25; i++) {
        put_char(i, ' ', 0x07, video);
    }
}

void kernel_main(void) {
    volatile char* video = (volatile char*) 0xB8000;
    
    // Effacer écran manuellement
    int i;
    for (i = 0; i < 80 * 25 * 2; i += 2) {
        video[i] = ' ';
        video[i + 1] = 0x07;
    }
    
    // Afficher message ligne par ligne
    int pos = 0;
    const char* texts[] = {"=== OOS ===", "Hello, World!", "Kernel running!"};
    for (i = 0; i < 3; i++) {
        const char* text = texts[i];
        int line_start = i * 80;
        int j = 0;
        while (text[j] != '\0') {
            video[line_start * 2 + j * 2] = text[j];
            video[line_start * 2 + j * 2 + 1] = (i == 0) ? 0x0F : ((i == 1) ? 0x0A : 0x09);
            j++;
        }
    }
    
    // Boucle infinie
    while (1) {
        asm("hlt");
    }
}

// Point d'entrée _start - doit être au tout début du kernel en 0x10000
asm(
    ".globl _start\n"
    ".code32\n"
    "_start:\n"
    "    mov $0x90000, %esp\n"          // initialiser stack
    "    mov $0x10, %ax\n"               // data segment selector
    "    mov %ax, %ds\n"
    "    mov %ax, %es\n"
    "    mov %ax, %fs\n"
    "    mov %ax, %gs\n"
    "    mov %ax, %ss\n"
    "    sti\n"                          // activer interruptions
    "    call kernel_main\n"
    "    cli\n"
    "    hlt\n"
    "    jmp .\n"
);

