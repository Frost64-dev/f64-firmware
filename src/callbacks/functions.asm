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
    ; fall through

.storage:
    ; fall through
    
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
    mov r0, 1
    ret

/* ModeSetFunc
 * Function to set video mode
 * Inputs: r0 = mode index
 * Outputs: r0 = 0 on success, 1 on failure
 */
ModeSetFunc:
    mov r0, 1
    ret

/* GetFBFunc
 * Function to get framebuffer address
 * Inputs: r0 = address to store framebuffer address
 * Outputs: r0 = 0 on success, 1 on failure
 */
GetFBFunc:
    mov r0, 1
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