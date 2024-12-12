# Copyright (©) 2024  Frosty515
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

ASM = frost64-asm
EMU = frost64-emu

export ASM EMU

all: clean
	@mkdir -p bin
	@$(ASM) -psrc/main.asm -obin/firmware.bin

clean:
	@rm -fr bin

bootloader:
	@$(ASM) -ptest/bootloader.asm -obin/bootloader.bin
	@mkdir -p image
	@dd if=/dev/zero of=image/disk.iso bs=1k count=8 &>/dev/null
	@dd if=bin/bootloader.bin of=image/disk.iso conv=notrunc &>/dev/null


run: all bootloader
	@$(EMU) -pbin/firmware.bin -Dimage/disk.iso