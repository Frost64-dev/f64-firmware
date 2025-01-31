# Copyright (©) 2024-2025  Frosty515

ASM = frost64-asm
EMU = frost64-emu

export ASM EMU

ifndef ENABLE_VIDEO
	ENABLE_VIDEO = 0
endif

all: clean
	@mkdir -p bin
	@$(ASM) -psrc/main.asm -obin/firmware.bin

clean:
	@rm -fr bin

bootloader:
	@$(ASM) -ptest/bootloader.asm -obin/bootloader.bin
	@$(ASM) -ptest/kernel.asm -obin/kernel.bin
	@mkdir -p image
	@dd if=/dev/zero of=image/disk.iso bs=512 count=17 &>/dev/null
	@dd if=bin/bootloader.bin of=image/disk.iso conv=notrunc &>/dev/null
	@dd if=bin/kernel.bin of=image/disk.iso seek=16 conv=notrunc &>/dev/null

run: all bootloader
ifeq ($(ENABLE_VIDEO), 1)
	@$(EMU) -pbin/firmware.bin -Dimage/disk.iso -dsdl
else
	@$(EMU) -pbin/firmware.bin -Dimage/disk.iso
endif