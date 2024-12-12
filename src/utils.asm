/* memset
 * This function fills a memory region with a given value.
 * Inputs: r0 = pointer to memory region, r1 = value to fill, r2 = number of bytes to fill
 * Outputs: r0 = pointer to memory region
 */
memset:
    push sbp
    mov sbp, scp
    push r0

    cmp r2, 0
    jz .end

    mov r3, 0 ; counter
.l:
    mov BYTE [r0 + r3], r1
    inc r3
    cmp r3, r2
    jl .l

.end:
    pop r0
    pop sbp
    ret

/* memcpy
 * This function copies a memory region to another memory region.
 * Inputs: r0 = destination, r1 = source, r2 = number of bytes to copy
 * Outputs: r0 = destination
 */
memcpy:
    push sbp
    mov sbp, scp
    push r0

    cmp r2, 0
    jz .end

    mov r3, 0 ; counter
.l:
    mov BYTE [r0 + r3], BYTE [r1 + r3]
    inc r3
    cmp r3, r2
    jl .l

.end:
    pop r0
    pop sbp
    ret
