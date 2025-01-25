org 0xF0000000

entry:
    mov sbp, stack
    mov scp, stack
    mov stp, stack_end
    call load_idt
    mov cr0, 1 ; enter protected mode
    jmp main

main:
    ; initialise the console device
    call Console_Init
    cmp r0, 0
    jnz .error

    ; initialise the video device
    call Video_Init
    cmp r0, 0
    jnz .no_video

    ; set video mode to 0
    mov r0, 0
    call Video_SetMode
    cmp r0, 0
    jnz .video_device_error

.no_video:
    ; initialise the storage device
    call Storage_Init
    cmp r0, 0
    jnz .storage_init_error

    ; read first 16 sectors to 0x1'0000
    mov r0, 0
    mov r1, 16
    mov r2, 0x10000
    call Storage_Read
    cmp r0, 0
    jnz .storage_read_error

    call BuildDeviceTable ; build the device table

    ; jump to the bootloader which should be at 0x1'0000
    mov r0, RootTable
    jmp 0x10000

.storage_init_error:
    mov r0, storage_init_error_msg
    jmp .print_error

.storage_read_error:
    mov r0, storage_read_error_msg
    jmp .print_error

.video_device_error:
    mov r0, video_device_error_msg
    jmp .print_error

.print_error:
    call Console_Print

.error: ; if there is no console device, then we can't print anything
    hlt

storage_init_error_msg:
    asciiz "Failed to initialise storage device\n"

storage_read_error_msg:
    asciiz "Failed to read from storage device\n"

video_device_error_msg:
    asciiz "Failed to initialise video device\n"

%include "callbacks/tables.asm"
%include "memory.asm"
%include "console.asm"
%include "idt.asm"
%include "IO.asm"
%include "stack.asm"
%include "storage.asm"
%include "utils.asm"
%include "video.asm"