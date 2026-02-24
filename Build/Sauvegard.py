import os
import sys
import time

WSL_PATH = "/mnt/c/Users/User/kDrive/OneOS/Build"

def run(cmd):
    full_cmd = f'wsl bash -c "cd {WSL_PATH} && {cmd}"'
    
    print(f"> {cmd}")
    result = os.system(full_cmd)

    if result != 0:
        print("\n❌ ERREUR ! Build stoppé.")
        sys.exit(1)

print("\n🚀 Démarrage de la compilation de FOS...")

#print("\n🔧 Nettoyage des anciens fichiers...")
#run("rm -f compiler/boot.bin compiler/kernel.o compiler/kernel.bin compiler/kernel.img os.bin")

print("🔧 Compilation du bootloader...")
run("nasm -f bin boot.asm -o compiler/boot.bin")

print("\n🔧 Compilation du kernel...")
run("gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -c kernel.c -o compiler/kernel.o")

print("\n🔧 Assemblage du point d'entrée...")
run("nasm -f elf32 kernel_start.asm -o compiler/kernel_start.o")

print("\n🔧 Link du kernel...")
run("ld -m elf_i386 -T linker.ld compiler/kernel_start.o compiler/kernel.o -o compiler/kernel.bin")

print("\n🔧 Conversion en binaire brut...")
run("objcopy -O binary compiler/kernel.bin compiler/kernel.img")

print("\n🔧 Création de l'image OS...")
run("cat compiler/boot.bin compiler/kernel.img > os.bin")

time.sleep(1)

print("\n✅ Terminé 😎🚀")

print("\nLancement de QEMU...")
run("qemu-system-i386 -drive format=raw,file=os.bin -serial stdio")