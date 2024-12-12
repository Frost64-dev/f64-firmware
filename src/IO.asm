%define IOBUS_COMMAND 0xFFFFFF00
%define IOBUS_STATUS 0xFFFFFF08
%define IOBUS_DATA0 0xFFFFFF10
%define IOBUS_DATA1 0xFFFFFF18
%define IOBUS_DATA2 0xFFFFFF20
%define IOBUS_DATA3 0xFFFFFF28

/* IOBus_SendCommand
 * Sends a command to the IOBus. Data should already be in the appropriate registers.
 * Input: r0 = Command
 * Output: r0 = Status, 0 for success, 1 for failure
 * Overwrites: r0 (rare case where this is reported)
 */
IOBus_SendCommand:
    mov QWORD [IOBUS_COMMAND], r0
.l:
    mov r0, QWORD [IOBUS_STATUS]
    and r0, 1
    cmp r0, 1
    jnz .l
    mov r0, QWORD [IOBUS_STATUS]
    and r0, 2
    shr r0, 1
    ret

/* IOBus_FindDevice
 * Finds a device on the IOBus.
 * Input: r0 = Device ID
 * Output: r0 = Index of device, -1 if not found
 */
IOBus_FindDevice:
    mov r3, r0 ; save device ID

    ; first run the Get bus info command to get the number of devices
    mov r0, 0
    call IOBus_SendCommand
    cmp r0, 0
    jnz .error
    mov r4, QWORD [IOBUS_DATA0] ; r4 = number of devices

    ; now run the Get device info command for each device
    xor r2, r2 ; r2 = index
.l:
    cmp r2, r4
    jz .error
    mov QWORD [IOBUS_DATA0], r2
    mov r0, 1
    call IOBus_SendCommand
    cmp r0, 0
    jnz .error
    mov r1, QWORD [IOBUS_DATA0] ; r1 = device ID
    cmp r1, r3
    jz .found
    inc r2
    jmp .l

.found:
    mov r0, r2
    ret

.error:
    mov r0, -1
    ret

/* IOBus_MapDevice
 * Maps a device on the IOBus.
 * Input: r0 = Device ID, r1 = Address
 * Output: r0 = Status, 0 for success, 1 for failure
 */
IOBus_MapDevice:
    mov QWORD [IOBUS_DATA0], r0
    mov QWORD [IOBUS_DATA1], r1
    mov r0, 2
    jmp IOBus_SendCommand ; IOBus_SendCommand will return the status as we need
