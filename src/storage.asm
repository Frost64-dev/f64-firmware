%define STORAGE_DEVICE_LOCATION 0xE0000100
%define STORAGE_DEVICE_COMMAND 0xE0000100
%define STORAGE_DEVICE_STATUS 0xE0000108
%define STORAGE_DEVICE_DATA 0xE0000110

/* Storage_Init
 * Initializes the storage device
 * Input: None
 * Output: r0 is 0 for success, 1 for failure
 */
Storage_Init:
    push r15

    ; find the storage device
    mov r0, 2
    call IOBus_FindDevice
    cmp r0, -1
    jz .error
    mov r15, r0 ; r15 = device index

    ; map the storage device
    mov r0, 2
    mov r1, STORAGE_DEVICE_LOCATION
    call IOBus_MapDevice
    cmp r0, 0
    jnz .error

    ; initialize the storage device
    mov QWORD [STORAGE_DEVICE_DATA], 1 ; enable, no interrupts
    mov r0, 0
    call Storage_Command
    cmp r0, 0
    jnz .error

    ; register the storage device
    mov r0, 2 ; device ID
    mov r1, r15 ; device index
    pop r15 ; restore r15
    jmp RegisterDevice ; can handle the rest

.error:
    mov r0, 1
    ret

/* Storage_Read
 * Reads data from the storage device
 * Input: r0 = LBA, r1 = count, r2 = buffer
 * Output: r0 = Status, 0 for success, 1 for failure
 */
Storage_Read:
    mov QWORD [Storage_Transfer], r0
    mov QWORD [Storage_Transfer+8], r1
    mov QWORD [Storage_PRL+8], r2
    mov QWORD [Storage_PRL+16], r1
    mov QWORD [STORAGE_DEVICE_DATA], Storage_Transfer
    mov r0, 2
    jmp Storage_Command ; handles the rest

/* Storage_Write
 * Writes data to the storage device
 * Input: r0 = LBA, r1 = count, r2 = buffer
 * Output: r0 = Status, 0 for success, 1 for failure
 */
Storage_Write:
    mov QWORD [Storage_Transfer], r0
    mov QWORD [Storage_Transfer+8], r1
    mov QWORD [Storage_PRL+8], r2
    mov QWORD [Storage_PRL+16], r1
    mov QWORD [STORAGE_DEVICE_DATA], Storage_Transfer
    mov r0, 3
    jmp Storage_Command ; handles the rest


/* Storage_Command
 * Sends a command to the storage device
 * Input: r0 = command
 * Output: r0 = Status, 0 for success, 1 for failure
 */
Storage_Command:
    mov QWORD [STORAGE_DEVICE_COMMAND], r0
.l:
    mov r0, QWORD [STORAGE_DEVICE_STATUS]
    and r0, 4
    cmp r0, 0
    jz .l
    mov r0, QWORD [STORAGE_DEVICE_STATUS]
    and r0, 2
    shr r0, 1
    ret

; some data buffers
Storage_PRL:
    dq 1 ; item count
    dq 0 ; physical address
    dq 0 ; sector count
    dq 0 ; next

Storage_Transfer:
    dq 0 ; LBA
    dq 0 ; count
    dq Storage_PRL ; PRLS
    dq 1 ; PRLSNC
    dq 0 ; flags
