# Frost64 Firmware Protocol

## Introduction

Very simple, work in progress

## Firmware Expectations

The firmware is expected to put the processor into protected mode, set-up a basic interrupt handling mechansim, detect and intialise any devices into a reasonable state.

## Loading the bootloader

The first 16 512-byte sectors on the storage device are reserved for the bootloader. The firmware is expected to load the bootloader from the storage device to 0x10000 and jump to it.

## The protocol

The protocol is a simple callback based system. The firmware is expected to provide a table which contains metadata and function pointers for various things.

### Calling conventions

#### Register Saving

- `r0` - `r7` are caller saved.
- `r8` - `r15` are callee saved.
- `stp` shouldn't be modified by the callee.
- `sbp` and `scp` are callee saved.

#### Arguments

- `r0` - `r3` are used for arguments.
- Any further arguments are passed on the stack in reverse order.

#### Return values

- `r0` is used for simple return values.
- `r1` can be used to extend the return value if needed.
- Anything bigger than 16 bytes will need to be either have its address passed as an argument or an address to a buffer gets returned.

#### Prologue

- The callee is expected to create a new stack frame by saving `sbp` to the stack, and then setting it to `scp`.
- This provides hardware level stack underflow/overflow protection.

#### Epilogue

- The callee is expected to restore `sbp` from the stack and then return.

### The table

#### Root table

The table root is expected to contain the following fields:

| Offset | Size | Name      | Description                          |
|--------|------|-----------|--------------------------------------|
| 0x00   | 8    | Magic     | A magic number to identify the table |
| 0x08   | 8    | Ver       | The version of the standard          |
| 0x10   | 8    | Name      | The name of the firmware             |
| 0x18   | 8    | Auth      | The author of the firmware           |
| 0x20   | 8    | FVer      | The version of the firmware          |
| 0x28   | 8    | DevTab    | The address of the device info table |
| 0x30   | 8    | DevTabLen | The length of the device info table  |
| 0x38   | 8    | MemTab    | The address of the memory info table |
| 0x40   | 8    | MemTabLen | The length of the memory info table  |

#### Device info table

The device info table is expected to contain the following fields:

| Offset | Size | Name       | Description                                            |
|--------|------|------------|--------------------------------------------------------|
| 0x00   | 8    | Magic      | A magic number to identify the table                   |
| 0x08   | 8    | Ver        | The version of the standard                            |
| 0x10   | 8    | DevNum     | The number of devices                                  |
| 0x18   | 8    | DevGetFunc | The address of the function to get info about a device |

Each device has a unique table which can get retrieved by calling the `DevGetFunc` function pointer with the device number as an argument. The device number is expected to be a 64-bit integer.

##### Device info table for a video device

The table is expected to contain the following fields:

| Offset | Size | Name        | Description                                          |
|--------|------|-------------|------------------------------------------------------|
| 0x00   | 4    | Width       | The native width of the screen in pixels             |
| 0x04   | 4    | Height      | The native height of the screen in pixels            |
| 0x08   | 1    | Depth       | The native depth of the screen in bits per pixel     |
| 0x09   | 3    | Align0      | Padding                                              |
| 0x0C   | 4    | ModeCount   | The number of supported modes                        |
| 0x20   | 8    | ModeGetFunc | The address of the function to get info about a mode |
| 0x80   | 8    | ModeSetFunc | The address of the function to set a mode            |
| 0x88   | 8    | GetFBFunc   | The address of the function to get the framebuffer   |

The table for each mode is expected to be as follows:

| Offset | Size | Name        | Description                               |
|--------|------|-------------|-------------------------------------------|
| 0x00   | 4    | Width       | The width of the screen in pixels         |
| 0x04   | 4    | Height      | The height of the screen in pixels        |
| 0x08   | 1    | Depth       | The depth of the screen in bits per pixel |
| 0x09   | 1    | Align0      | Padding                                   |
| 0x0A   | 2    | RefreshRate | The refresh rate of the screen in Hz      |
| 0x0C   | 4    | Align1      | Padding                                   |
| 0x10   | 1    | RedSize     | The red size of each pixel                |
| 0x11   | 1    | GreenSize   | The green size of each pixel              |
| 0x12   | 1    | BlueSize    | The blue size of each pixel               |
| 0x13   | 1    | AlphaSize   | The alpha size of each pixel              |
| 0x14   | 1    | RedShift    | The red shift in each pixel               |
| 0x15   | 1    | GreenShift  | The green shift in each pixel             |
| 0x16   | 1    | BlueShift   | The blue shift in each pixel              |
| 0x17   | 1    | AlphaShift  | The alpha shift in each pixel             |

#### Device info table for a console device

The table is expected to contain the following fields:

| Offset | Size | Name        | Description                                   |
|--------|------|-------------|-----------------------------------------------|
| 0x00   | 8    | PrintFunc   | The address of the function to print a string |

#### Memory info table

The memory info table is expected to contain the following fields:

| Offset | Size | Name       | Description                                                   |
|--------|------|------------|---------------------------------------------------------------|
| 0x00   | 8    | Magic      | A magic number to identify the table                          |
| 0x08   | 8    | Ver        | The version of the standard                                   |
| 0x10   | 8    | MemNum     | The number of memory regions                                  |
| 0x18   | 8    | MemGetFunc | The address of the function to get info about a memory region |

The returned table for each memory region is expected to be as follows:

| Offset | Size | Name        | Description                           |
|--------|------|-------------|---------------------------------------|
| 0x00   | 8    | Base        | The base address of the memory region |
| 0x08   | 8    | Size        | The size of the memory region         |
| 0x10   | 8    | Type        | The type of the memory region         |

The type is expected to be one of the following:

- 0x00 - Available
- 0x01 - Firmware
- 0x02 - Reserved
- 0x03 - Framebuffer
- 0x04 - Bootloader

### The functions

The functions are expected to be called as described in the calling conventions section.

#### DevGetFunc

The function has 2 arguments:

- `r0` - The device index
- `r1` - A pointer to a buffer to store the device info table

The functions returns the following:

- `r0` - Device ID, -1 if the device doesn't exist

If the pointer is 0 the function won't copy the table to the buffer, but will still return the device ID.

### Memory map

As there is no way to detect how much RAM is available, the firmware will just say all of unused address space is available.

### Notes

- The protocol is not fully implemented, or even fully designed yet. It is subject to change at any time without any notice.
- The current firmware only supports the device subtable, with only the console device implemented.
