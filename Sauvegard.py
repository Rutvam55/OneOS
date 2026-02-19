import os
import sys
import time

WSL_PATH = "/mnt/c/Users/User/OS"

def run(cmd):
    full_cmd = f'wsl bash -c "cd {WSL_PATH} && {cmd}"'

    print(f"> {cmd}")
    result = os.system(full_cmd)

    if result != 0:
        print("\n❌ ERREUR ! Build stoppé.")
        sys.exit(1)

print("🚀 Démarrage de la compilation...")

print("🔧 Nettoyage des anciens fichiers...")
run("rm -f boot.bin kernel.o kernel.bin kernel.img os.bin")

print("🔧 Compilation du bootloader...")
run("nasm -f bin boot_noload.asm -o boot.bin")

print("\n🔧 Compilation du kernel...")
run("gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -c kernel.c -o kernel.o")

print("\n🔧 Link du kernel...")
run("ld -m elf_i386 -T linker.ld kernel.o -o kernel.bin")

print("\n🔧 Conversion en binaire brut...")
run("objcopy -O binary kernel.bin kernel.img")

print("\n🔧 Création de l'image OS...")
run("python3 build_img.py")

time.sleep(1)

print("\n✅ Terminé 😎🚀")

print("\nLancement de QEMU...")
run("qemu-system-i386 -drive format=raw,file=os.bin")