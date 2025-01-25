# f64-firmware

Official firmware for the Frost64

## COPYING

Copyright (©) 2024-2025  Frosty515

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Protocol

The protocol for the Frost64 firmware is documented in the [PROTOCOL.md](PROTOCOL.md) file.

## Building & Running

To build and run the firmware, you will need both the assembler and emulator installed in your `PATH`.

### Building

- run `make` to build the firmware

### Running

- run `make run` to build and run the firmware

## Scripts

The `scripts/` directory contains various scripts that were used to generate parts of the firmware. There is no guarantee that these scripts will work on your system, but they are provided for reference. They can be in a variety of different programming languages as they are not required to build or run the firmware.

## Test bootloader

The `test/` directory contains the test bootloader. The test bootloader is used to test the firmware and ensure that it is working correctly. It is not required to build the firmware, but is required to run the firmware.
