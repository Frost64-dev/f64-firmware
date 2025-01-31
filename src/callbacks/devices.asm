/* BuildDeviceTable
 * This function is called by the BIOS to build the device table. It is
 * responsible for initializing the device table with the device
 * descriptors for all devices that are present in the system.
 * Inputs: none
 * Outputs: none
 */
BuildDeviceTable:
    ; loop through the device table
    mov r2, 0 ; counter
.l:
    ; use r3 as an offset for accessing the second part of a node in the table
    mov r3, Internal_DeviceTable
    add r3, 8
    mov r0, QWORD [r2 * 16 + r3]
    cmp r0, 1
    jnz .goto_next
    mov r0, QWORD [r2 * 16 + Internal_DeviceTable] ; device ID
    call GetDeviceTable ; only replaces r0
    cmp r0, 0
    jz .goto_next
    mov QWORD [r2 * 16 + r3], r0 ; replace the flag with the table pointer
    inc QWORD [DeviceTable + 16] ; increment the number of devices
    ; fall through
.goto_next:
    inc r2
    cmp r2, 3
    jl .l

    ret


/* RegisterDevice
 * This function is called by the BIOS to register a device with the
 * device table. It is responsible for adding the device descriptor to
 * the device table.
 * Inputs: r0 = device ID, r1 = device index
 * Outputs: r0 = 0 on success, 1 on failure
 */
RegisterDevice:
    ; check the index is <= 2
    cmp r1, 2
    jg .error
    mov QWORD [r1 * 16 + Internal_DeviceTable], r0
    mov r2, Internal_DeviceTable
    add r2, 8
    ; the pointer to the table for the device gets used as a flag just for now
    mov QWORD [r1 * 16 + r2], 1 ; set the device as present
    mov r0, 0
    ret

.error:
    mov r0, 1
    ret

/* GetDeviceTable
 * This function is called by the BIOS to get the table for a device.
 * Inputs: r0 = device ID
 * Outputs: r0 = pointer to the device table, 0 if not found
 * Overwrites: r0 (rare case where this is reported)
 */
GetDeviceTable:
    cmp r0, 2
    jg .not_found

    cmp r0, 1
    jl .console
    jz .video
    jg .storage

    ; unreachable

.console:
    mov r0, ConsoleDeviceTable
    ret

.video:
    mov r0, VideoDeviceTable
    ret

.storage:
    mov r0, StorageDeviceTable
    ret

.not_found:
    mov r0, 0
    ret

/* GetDeviceIndex
 * This functions gets the device index from the ID
 * Inputs: r0 = device ID
 * Outputs: r0 = device index, -1 for invalid
 */
GetDeviceIndex:
    ; loop through the device table
    mov r1, 0 ; counter
.l:
    cmp QWORD [r1 * 16 + Internal_DeviceTable], r0
    jz .found
    inc r1
    cmp r1, 2
    jle .l

    mov r0, -1
    ret

.found:
    mov r0, r1
    ret