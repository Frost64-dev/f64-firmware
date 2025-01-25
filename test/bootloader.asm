org 0x10000

main: ; r0 = pointer to root table
    mov r15, r0 ; save root table

    mov r14, QWORD [r15 + 0x28] ; device table
    mov r12, QWORD [r14 + 0x10] ; number of devices
    mov r13, QWORD [r14 + 0x18] ; device get info callback
    ; enumerate through the device looking for the console device
    mov r0, 0 ; device ID
    mov r1, r12 ; number of devices
    mov r2, r13 ; device get info callback
    call FindDevice
    cmp r0, -1
    jz .end


    mov r1, buffer
    call r13 ; actually get the callback to give us the device info
    cmp r0, -1
    jz .end

    mov r0, message
    call QWORD [buffer] ; call the print function the firmware provides
    
.end:
    hlt

/* FindDevice
 * Function to find a device on the IOBus
 * Inputs: r0 = Device ID, r1 = number of devices, r2 = device get info callback
 * Outputs: r0 = Index of device, -1 if not found
 */
FindDevice:
    push sbp
    mov sbp, scp

    mov r3, 0 ; counter
.l:
    push r3 ; save the registers
    push r1
    push r2
    push r0
    mov r0, r3 ; device index
    mov r1, 0 ; address to store device info
    call r2 ; call the callback with no address for the device info so it just gives us the device ID
    pop r1
    cmp r0, r1
    jz .found
    mov r0, r1
    pop r2
    pop r1
    pop r3

    inc r3
    cmp r3, r1
    jle .l

.error:
    mov r0, -1
    jmp .end

.found:
    sub scp, 16
    pop r0 ; index

.end:
    pop sbp
    ret

buffer:
    dq 0

message:
    asciiz "Hello from the bootloader!\n"