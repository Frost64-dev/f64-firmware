%define CONSOLE_DEVICE_LOCATION 0xE0000000

/* Console_Init
 * Initializes the console device
 * Input: None
 * Output: r0 is 0 for success, 1 for failure
 */
Console_Init:
    push r15
    mov r0, 0
    call IOBus_FindDevice
    cmp r0, -1
    jz .error
    mov r15, r0 ; r15 = device index

    mov r0, 0
    mov r1, CONSOLE_DEVICE_LOCATION
    call IOBus_MapDevice
    cmp r0, 0
    jnz .error

    mov r0, 0 ; device ID
    mov r1, r15 ; device index
    pop r15 ; restore r15
    jmp RegisterDevice ; can handle the rest

.error:
    mov r0, 1
    ret

/* Console_Print
 * Prints a null-terminated string to the console
 * Input: r0 = null-terminated string
 * Output: None
 */
Console_Print: ; r0 = null-terminated string
    mov r1, 0 ; use r1 as counter
.l:
    mov r2, BYTE [r0+r1]
    cmp BYTE r2, 0
    jz .end
    mov BYTE [CONSOLE_DEVICE_LOCATION], BYTE r2
    inc r1
    jmp .l
.end:
    ret
