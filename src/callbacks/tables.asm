RootTable: ; 9 qwords, 72 bytes
    ascii "ROOTTBLE" ; magic number, 8 bytes
    dq 0 ; standard version
    ascii "OFFICIAL" ; name, 8 bytes
    ascii "Frsty515" ; author, 8 bytes
    dq 0 ; firmware version
    dq DeviceTable
    dq 32 ; length of the device table
    dq MemoryTable
    dq 32 ; length of the memory table

DeviceTable: ; 4 qwords, 32 bytes
    ascii "DEVCTBLE" ; magic number, 8 bytes
    dq 0 ; standard version
    dq 0 ; number of devices
    dq DevGetFunc ; function to get info about device

VideoDeviceTable: ; 5 qwords, 40 bytes
    dd 0 ; native width
    dd 0 ; native height
    db 0 ; native colour depth in bits per pixel
    db 0 ; alignment
    dw 0 ; alignment
    dd 0 ; Mode count
    dq ModeGetFunc ; Get mode info function
    dq ModeSetFunc ; Set mode function
    dq GetFBFunc ; Get framebuffer function

VideoModeTable: ; 3 qwords, 24 bytes
    dd 0 ; width
    dd 0 ; height
    db 0 ; colour depth in bits per pixel
    db 0 ; alignment
    dw 0 ; refresh rate
    dd 0 ; alignment
    db 0 ; red size in bits
    db 0 ; green size in bits
    db 0 ; blue size in bits
    db 0 ; alpha size in bits
    db 0 ; red shift
    db 0 ; green shift
    db 0 ; blue shift
    db 0 ; alpha shift

ConsoleDeviceTable: ; 1 qword, 8 bytes
    dq PrintFunc ; Print function

StorageDeviceTable: ; 4 qwords, 32 bytes
    dq 0 ; sector count
    dw 0 ; sector size
    dw 0 ; alignment
    dd 0 ; alignment
    dq ReadFunc ; Read function
    dq WriteFunc ; Write function

MemoryTable: ; 4 qwords, 32 bytes
    ascii "MEMRYTBL" ; magic number, 8 bytes
    dq 0 ; standard version
    dq 9 ; number of memory regions
    dq MemGetFunc ; function to get info about memory region

Internal_DeviceTable: ; 6 qword, 48 bytes
    dq 0 ; device 0 ID
    dq 0 ; device 0 table
    dq 0 ; device 1 ID
    dq 0 ; device 1 table
    dq 0 ; device 2 ID
    dq 0 ; device 2 table

%include "functions.asm"
%include "devices.asm"