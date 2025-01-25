%define VIDEO_DEVICE_COMMAND 0xE0000200
%define VIDEO_DEVICE_DATA 0xE0000208
%define VIDEO_DEVICE_STATUS 0xE0000210
%define VIDEO_FRAMEBUFFER_ADDRESS 0x80000000

/* Video_Init
 * Initializes the video device
 * Input: None
 * Output: r0 is 0 for success, 1 for failure
 */
Video_Init:
    push sbp
    mov sbp, scp
    push r15

    ; find the video device
    mov r0, 1
    call IOBus_FindDevice
    cmp r0, -1
    jz .error
    mov r15, r0 ; r15 = device index

    ; map the video device
    mov r0, 1
    mov r1, VIDEO_DEVICE_COMMAND
    call IOBus_MapDevice
    cmp r0, 0
    jnz .error

    ; initialize the video device
    mov r0, 0
    call Video_Command
    cmp r0, 0
    jnz .error

    ; register the video device
    mov r0, 1 ; device ID
    mov r1, r15 ; device index
    pop r15 ; restore r15
    call RegisterDevice
    cmp r0, 0
    jnz .error2

    ; next get some info about the device
    mov QWORD [VIDEO_DEVICE_DATA], Video_GetScreenInfoBuffer
    mov r0, 1
    call Video_Command
    cmp r0, 0
    jnz .error2

    ; copy the data to the global tables
    mov DWORD [VideoDeviceTable], DWORD [Video_GetScreenInfoBuffer]
    mov DWORD [VideoDeviceTable+4], DWORD [Video_GetScreenInfoBuffer+4]
    mov BYTE [VideoDeviceTable+8], WORD [Video_GetScreenInfoBuffer+10] ; bpp
    mov WORD [VideoDeviceTable+12], WORD [Video_GetScreenInfoBuffer+12] ; number of modes

    jmp .end

.error:
    pop r15
    ; fall through

.error2:
    mov r0, 1
    ; fall through

.end:
    pop sbp
    ret

/* Video_GetMode
 * Gets the video mode, setting the data in the global table
 * Inputs: r0 = mode index
 * Outputs: r0 = 0 for success, 1 for failure
 */
Video_GetMode:
    push sbp
    mov sbp, scp

    mov WORD [Video_GetGetModeInfoInBuffer+8], r0 ; mode index
    mov QWORD [VIDEO_DEVICE_DATA], Video_GetGetModeInfoInBuffer
    mov r0, 2
    call Video_Command
    cmp r0, 0
    jnz .error

    ; copy the data to the global tables
    mov DWORD [VideoModeTable], DWORD [Video_GetModeInfoOutBuffer]
    mov DWORD [VideoModeTable+4], DWORD [Video_GetModeInfoOutBuffer+4]
    mov BYTE [VideoModeTable+8], WORD [Video_GetModeInfoOutBuffer+8] ; bpp
    mov WORD [VideoModeTable+10], WORD [Video_GetModeInfoOutBuffer+14] ; refresh rate
    mov BYTE [VideoModeTable+16], 8 ; red size in bits
    mov BYTE [VideoModeTable+17], 8 ; green size in bits
    mov BYTE [VideoModeTable+18], 8 ; blue size in bits
    mov BYTE [VideoModeTable+19], 8 ; alpha size in bits
    mov BYTE [VideoModeTable+20], 16 ; red shift
    mov BYTE [VideoModeTable+21], 8 ; green shift
    mov BYTE [VideoModeTable+22], 0 ; blue shift
    mov BYTE [VideoModeTable+23], 24 ; alpha shift
    
    jmp .end

.error:
    mov r0, 1
    ; fall through

.end:
    pop sbp
    ret

/* Video_SetMode
 * Sets the video mode
 * Inputs: r0 = mode index
 * Outputs: r0 = 0 for success, 1 for failure
 */
Video_SetMode:
    push sbp
    mov sbp, scp

    mov WORD [Video_SetModeInfoBuffer+8], r0 ; mode index
    mov QWORD [VIDEO_DEVICE_DATA], Video_SetModeInfoBuffer
    mov r0, 3
    call Video_Command
    cmp r0, 0
    jnz .error

    jmp .end

.error:
    mov r0, 1
    ; fall through

.end:
    pop sbp
    ret

/* Video_Command
 * Sends a command to the video device
 * Input: r0 = command
 * Output: r0 = Status, 0 for success, 1 for failure
 * Overwrites: r0 (rare case where this is reported)
 */
Video_Command:
    mov QWORD [VIDEO_DEVICE_COMMAND], r0
    mov r0, QWORD [VIDEO_DEVICE_STATUS]
    ret

Video_GetScreenInfoBuffer:
    dd 0 ; width
    dd 0 ; height
    dw 0 ; refresh rate
    dw 0 ; bpp
    dw 0 ; number of modes
    dw 0 ; current mode

Video_GetGetModeInfoInBuffer:
    dq Video_GetModeInfoOutBuffer
    dw 0 ; mode index
    dw 0 ; padding
    dd 0 ; padding

Video_GetModeInfoOutBuffer:
    dd 0 ; width
    dd 0 ; height
    dw 0 ; bpp
    dd 0 ; pitch
    dw 0 ; refresh rate

Video_SetModeInfoBuffer:
    dq VIDEO_FRAMEBUFFER_ADDRESS
    dw 0 ; mode index
    dw 0 ; padding
    dd 0 ; padding