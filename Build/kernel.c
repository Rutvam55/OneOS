void line(char* str, char color, char* video, int line_number) {
    int start_pos = line_number * 80;
    for (int i = 0; str[i] != '\0'; i++) {
        put_char(start_pos + i, str[i], color, video);
    }
}

void print_hex(unsigned char value, int line_number, char* video) {
    char hex[] = "0123456789ABCDEF";
    
    char buffer[3];
    buffer[0] = hex[(value >> 4) & 0xF];
    buffer[1] = hex[value & 0xF];
    buffer[2] = '\0';
    
    line(buffer, 0x0A, video, line_number);
}

void put_char(int pos, char c, char color, char* video) {
    video[pos * 2] = c;
    video[pos * 2 + 1] = color;
}

void clear_screen(char* video) {
    for (int i = 0; i < 80 * 25; i++) {
        put_char(i, ' ', 0x07, video);
    }
}

// --- Serial (COM1) I/O for debugging ---
#define COM1_PORT 0x3F8

static inline void outb(unsigned short port, unsigned char val) {
    asm volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline unsigned char inb(unsigned short port) {
    unsigned char ret;
    asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static int serial_is_transmit_empty() {
    return inb(COM1_PORT + 5) & 0x20;
}

static void serial_write_char(char c) {
    while (!serial_is_transmit_empty()) { }
    outb(COM1_PORT, c);
}

static void serial_write_string(const char* s) {
    for (int i = 0; s[i] != '\0'; i++) {
        if (s[i] == '\n') serial_write_char('\r');
        serial_write_char(s[i]);
    }
}

static void serial_init() {
    outb(COM1_PORT + 1, 0x00);    // Disable all interrupts
    outb(COM1_PORT + 3, 0x80);    // Enable DLAB (set baud rate divisor)
    outb(COM1_PORT + 0, 0x03);    // Set divisor to 3 (lo byte)
    outb(COM1_PORT + 1, 0x00);    //                  (hi byte)
    outb(COM1_PORT + 3, 0x03);    // 8 bits, no parity, one stop bit
    outb(COM1_PORT + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
    outb(COM1_PORT + 4, 0x0B);    // IRQs enabled, RTS/DSR set
}

void print_hex_at(unsigned char value, char* video, int pos) {
    char hex[] = "0123456789ABCDEF";

    video[pos * 2]     = hex[(value >> 4) & 0xF];
    video[pos * 2 + 1] = 0x0A;

    video[(pos + 1) * 2]     = hex[value & 0xF];
    video[(pos + 1) * 2 + 1] = 0x0A;
}

void kernel_main() {
    char* video = (char*) 0xB8000;
    clear_screen(video);
    serial_init();
    serial_write_string("Flexible OS: kernel_main()\n");

    char state = 0;
    int cursor = 0;

    /*
    line(" Time 12:30  Ram  99%  Battery 100%                                           ", 0x07, video, 0);
    line("==============================================================================", 0x07, video, 1);
    line(" [1] Terminal                                                                 ", 0x07, video, 2);
    line(" [2] Settings                                                                 ", 0x07, video, 3);
    line(" [3] File Explorer                                                            ", 0x07, video, 4);
    line(" [4] Internet        .........    .......     .......                         ", 0x07, video, 5);
    line("                     .........   .........   .........                        ", 0x07, video, 6);
    line("                     .........   .........   .........                        ", 0x07, video, 7);
    line("                     :::         :::   :::   :::   ...                        ", 0x07, video, 8);
    line("                     :::         :::   :::   :::                              ", 0x07, video, 9);
    line("                     :::         :::   :::   :::                              ", 0x07, video, 10);
    line("                     ======      ===   ===   ========                         ", 0x07, video, 11);
    line("                     ======      ===   ===   =========                        ", 0x07, video, 12);
    line("                     ======      ===   ===    ========                        ", 0x07, video, 13);
    line("                     ###         ###   ###         ###                        ", 0x07, video, 14);
    line("                     ###         ###   ###         ###                        ", 0x07, video, 15);
    line("                     ###         ###   ###   ###   ###                        ", 0x07, video, 16);
    line("                     ###         #########   #########                        ", 0x07, video, 17);
    line("                     ###         #########   #########                        ", 0x07, video, 18);
    line("                     ###          #######     #######                         ", 0x07, video, 19);
    line("                                                                              ", 0x07, video, 20);
    line("                                                                              ", 0x07, video, 21);
    line("                                                                              ", 0x07, video, 22);
    line("==============================================================================", 0x07, video, 23);
    line(" FOS  [Search]>                                                               ", 0x07, video, 24);
    */
    
    
    
    serial_write_string("Flexible OS: finished init, entering loop\n");
    while (1) {

        if (inb(0x64) & 1) {

            unsigned char scancode = inb(0x60);

            char scancode_to_ascii[128] = {
                0, 27, '1','2','3','4','5','6','7','8','9','0','-','=','\b',
                '\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',
                0,'a','s','d','f','g','h','j','k','l',';','\'','`',
                0,'\\','z','x','c','v','b','n','m',',','.','/',
            };
            char ch = scancode_to_ascii[scancode];
            char tmp[2];
            tmp[0] = ch;
            tmp[1] = '\0';

            line(tmp, 0x0A, video, 1);
            
            print_hex_at(scancode, video, cursor);

            cursor += 3;   // espace entre valeurs

            if (cursor >= 80 * 25)
                cursor = 0;
        }
    }
}

