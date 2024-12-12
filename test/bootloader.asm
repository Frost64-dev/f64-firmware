org 0x10000

main: ; r0 = pointer to root table
    mov r15, r0 ; save root table

    mov r14, QWORD [r15 + 0x28] ; device table
    mov r2, QWORD [r14 + 0x10] ; number of devices
    mov r13, QWORD [r14 + 0x18] ; device get info callback
    ; enumerate through the device looking for the console device
    mov r0, 0 ; counter
.l:
    push r0 ; save the registers
    push r2
    push r3
    mov r1, 0 ; address to store device info
    call r13 ; call the callback with no address for the device info so it just gives us the device ID
    pop r3
    pop r2
    cmp r0, -1
    jz .end

    cmp r0, 0 ; device ID for console device
    jz .found

    pop r0
    inc r0
    cmp r0, r2
    jle .l

    jmp .end

.found:
    pop r0 ; index
    mov r1, buffer
    call r13 ; actually get the callback to give us the device info
    cmp r0, -1
    jz .end

    mov r0, message
    call QWORD [buffer] ; call the print function the firmware provides

.end:
    pop r0 ; put the stack back to normal
    hlt

buffer:
    dq 0

message:
    asciiz "Hello from the bootloader!\n"