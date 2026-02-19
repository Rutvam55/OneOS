boot = open("boot.bin", "rb").read()
kernel = open("kernel.img", "rb").read()

f = open("os.bin", "wb")

f.write(boot)

# Padding jusqu'à 0x10000
f.write(bytes(65536 - len(boot)))

f.write(kernel)

f.close()

print("Image OS créée 😎🔥")