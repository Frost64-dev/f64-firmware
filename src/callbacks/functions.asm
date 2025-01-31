/* DevGetFunc
 * Function to get info about device
 * Inputs: r0 = device index, r1 = address to store device info
 * Outputs: r0 = device ID, -1 on failure
 */
DevGetFunc:
    push sbp
    mov sbp, scp

    cmp r0, 2
    jg .fail

    cmp r1, 0
    jnz .continue
    mov r0, QWORD [r0 * 16 + Internal_DeviceTable]
    jmp .end

.continue:
    mov r3, r0 ; save r0

    ; use r2 for size

    mov r0, QWORD [r0 * 16 + Internal_DeviceTable] ; convert index to ID

    cmp r0, 1
    jl .console
    jz .video
    jg .storage

    ; unreachable

.have_size:
    mov r0, r1
    mov r4, Internal_DeviceTable
    add r4, 8
    mov r1, QWORD [r3 * 16 + r4]
    call memcpy
    mov r0, QWORD [r0 * 16 + Internal_DeviceTable]
    jmp .end

.console:
    mov r2, 8
    jmp .have_size

.video:
    mov r2, 40
    jmp .have_size

.storage:
    mov r2, 32
    jmp .have_size
    
.fail:
    mov r0, -1

.end:
    pop sbp
    ret

/* ModeGetFunc
 * Function to get info about video mode
 * Inputs: r0 = mode index, r1 = address to store mode info
 * Outputs: r0 = 0 on success, 1 on failure
 */
ModeGetFunc:
    push sbp
    mov sbp, scp

    push r15
    push r14

    mov r14, r0
    mov r15, r1

    ; validate that the memory is accessible
    mov r0, r1
    mov r1, 24
    call Memory_ValidateAccess
    cmp r0, 0
    jnz .fail

    ; next verify that the index is valid
    cmp r14, DWORD [VideoDeviceTable+12]
    jge .fail

    ; then get the mode info
    mov r0, r14
    call Video_GetMode
    cmp r0, 0
    jnz .fail

    ; copy the data to the buffer
    mov r0, r15
    mov r1, VideoModeTable
    mov r2, 24
    call memcpy

    mov r0, 0
    jmp .end

.fail:
    mov r0, 1

.end:
    pop r14
    pop r15
    pop sbp
    ret

/* ModeSetFunc
 * Function to set video mode
 * Inputs: r0 = mode index
 * Outputs: r0 = 0 on success, 1 on failure
 */
ModeSetFunc:
    push sbp
    mov sbp, scp
    
    ; verify that the index is valid
    cmp r0, DWORD [VideoDeviceTable+12]
    jge .fail

    ; set the mode
    call Video_SetMode
    cmp r0, 0
    jnz .fail

    mov r0, 0
    jmp .end

.fail:
    mov r0, 1

.end:
    pop sbp
    ret

/* GetFBFunc
 * Function to get framebuffer address
 * Inputs: r0 = address to store framebuffer address
 * Outputs: r0 = 0 on success, 1 on failure
 */
GetFBFunc:
    push sbp
    mov sbp, scp

    push r0

    ; validate that the memory is accessible
    mov r1, 8
    call Memory_ValidateAccess
    cmp r0, 0
    jnz .fail

    ; copy the framebuffer address to the buffer
    pop r0
    mov QWORD [r0], VIDEO_FRAMEBUFFER_ADDRESS

    mov r0, 0
    jmp .end

.fail:
    pop r0
    mov r0, 1

.end:
    pop sbp
    ret

/* PrintFunc
 * Function to print a string to the console
 * Inputs: r0 = address of string
 * Outputs: r0 = 0 on success, 1 on failure
 */
PrintFunc:
    ; for now
    call Console_Print
    mov r0, 0
    ret

/* MemGetFunc
 * Function to get info about memory region
 * Inputs: r0 = memory region index, r1 = address to store memory region info
 * Outputs: r0 = 0 on success, 1 on failure
 */
MemGetFunc:
    mov r0, 1
    ret

/* ReadFunc
 * Function to read from storage device
 * Inputs: r0 = starting LBA, r1 = number of sectors, r2 = address to store data
 * Outputs: r0 = 0 on success, 1 on failure
 */
ReadFunc:
    push sbp
    mov sbp, scp

    push r15
    push r14
    push r13

    mov r13, r0
    mov r14, r1
    mov r15, r2

    ; first check that the memory is accessible
    mov r0, r2
    mov r1, r1
    shl r1, 9
    call Memory_ValidateAccess
    cmp r0, 0
    jnz .fail

    ; next ensure the LBA + number of sectors is valid
    mov r0, r13
    add r0, r14
    cmp r0, QWORD [Storage_Info+8]
    jg .fail

    mov r0, r13
    mov r1, r14
    mov r2, r15

    pop r13
    pop r14
    pop r15

    mov scp, sbp
    pop sbp

    jmp Storage_Read

.fail:
    mov r0, 1

.end:
    mov scp, sbp
    pop sbp
    ret

/* WriteFunc
 * Function to write to storage device
 * Inputs: r0 = starting LBA, r1 = number of sectors, r2 = address of data
 * Outputs: r0 = 0 on success, 1 on failure
 */
WriteFunc:
    push sbp
    mov sbp, scp

    push r15
    push r14
    push r13

    mov r13, r0
    mov r14, r1
    mov r15, r2

    ; first check that the memory is accessible
    mov r0, r2
    mov r1, r1
    shl r1, 9
    call Memory_ValidateAccess
    cmp r0, 0
    jnz .fail

    ; next ensure the LBA + number of sectors is valid
    mov r0, r13
    add r0, r14
    cmp r0, QWORD [Storage_Info+8]
    jg .fail

    mov r0, r13
    mov r1, r14
    mov r2, r15

    pop r13
    pop r14
    pop r15

    mov scp, sbp
    pop sbp

    jmp Storage_Write

.fail:
    mov r0, 1

.end:
    mov scp, sbp
    pop sbp
    ret
