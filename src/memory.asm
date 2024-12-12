%define MEMORY_MAP_ENTRY_AVAILABLE 0
%define MEMORY_MAP_ENTRY_FIRMWARE 1
%define MEMORY_MAP_ENTRY_RESERVED 2
%define MEMORY_MAP_ENTRY_FRAMEBUFFER 3
%define MEMORY_MAP_ENTRY_BOOTLOADER 4

MemoryMap_Entry0: ; very low memory
    dq 0x0 ; base
    dq 0x10000 ; length
    dq MEMORY_MAP_ENTRY_AVAILABLE ; type
MemoryMap_Entry1: ; bootloader
    dq 0x10000 ; base
    dq 0x2000 ; length
    dq MEMORY_MAP_ENTRY_BOOTLOADER ; type
MemoryMap_Entry2: ; low memory
    dq 0x12000 ; base
    dq 0x7FFEE000 ; length
    dq MEMORY_MAP_ENTRY_AVAILABLE ; type
MemoryMap_Entry3: ; framebuffer
    dq 0x80000000 ; base
    dq 0x800000 ; length, hardcoded as maximum possible size aligned up to be a power of 2
    dq MEMORY_MAP_ENTRY_FRAMEBUFFER ; type
MemoryMap_Entry4: ; middle memory
    dq 0x80800000 ; base
    dq 0x5F800000 ; length
    dq MEMORY_MAP_ENTRY_AVAILABLE ; type
MemoryMap_Entry5: ; reserved
    dq 0xE0000000 ; base
    dq 0x10000000 ; length
    dq MEMORY_MAP_ENTRY_RESERVED ; type
MemoryMap_Entry6: ; firmware
    dq 0xF0000000 ; base
    dq 0xFFFFFF00 ; length
    dq MEMORY_MAP_ENTRY_FIRMWARE ; type
MemoryMap_Entry7: ; more reserved
    dq 0xFFFFFF00 ; base
    dq 0x100 ; length
    dq MEMORY_MAP_ENTRY_RESERVED ; type
MemoryMap_Entry8: ; high memory
    dq 0x100000000 ; base
    dq 0xFFFFFFFF00000000 ; length
    dq MEMORY_MAP_ENTRY_AVAILABLE ; type

/* Memory_ValidateAccess
 * Function to validate access to a memory region. Checks if the region is within one of the available memory regions.
 * Inputs: r0 = base, r1 = length
 * Outputs: r0 = 0 on success, 1 on failure
 */
Memory_ValidateAccess:
    push sbp
    mov sbp, scp

    ; first test if it is in the lowest region
    push r0
    push r1
    mov r2, QWORD [MemoryMap_Entry0]
    mov r3, QWORD [MemoryMap_Entry0 + 8]
    call Memory_IsInRegion
    cmp r0, 1
    jz .valid
    
    ; then test if it is in the bootloader region
    mov r0, QWORD [sbp + 8]
    mov r1, QWORD [sbp + 16]
    mov r2, QWORD [MemoryMap_Entry1]
    mov r3, QWORD [MemoryMap_Entry1 + 8]
    call Memory_IsInRegion
    cmp r0, 1
    jz .valid

    ; then test if it is in the low memory region
    mov r0, QWORD [sbp + 8]
    mov r1, QWORD [sbp + 16]
    mov r2, QWORD [MemoryMap_Entry2]
    mov r3, QWORD [MemoryMap_Entry2 + 8]
    call Memory_IsInRegion
    cmp r0, 1
    jz .valid

    ; then test if it is in the middle memory region
    mov r0, QWORD [sbp + 8]
    mov r1, QWORD [sbp + 16]
    mov r2, QWORD [MemoryMap_Entry4]
    mov r3, QWORD [MemoryMap_Entry4 + 8]
    call Memory_IsInRegion
    cmp r0, 1
    jz .valid

    ; then test if it is in the high memory region
    mov r0, QWORD [sbp + 8]
    mov r1, QWORD [sbp + 16]
    mov r2, QWORD [MemoryMap_Entry8]
    mov r3, QWORD [MemoryMap_Entry8 + 8]
    call Memory_IsInRegion
    cmp r0, 1
    jz .valid

    ; if it is not in any of the regions, return 1

    mov r0, 1
    jmp .end

.valid:
    mov r0, 0

.end:
    sub scp, 16
    pop sbp
    ret


/* Memory_IsInRegion
 * Function to check if a memory region is within a specific region.
 * Inputs: r0 = base, r1 = length, r2 = region base, r3 = region length
 * Outputs: r0 = 0 if the region is not within the specified region, 1 if it is
 */
Memory_IsInRegion:
    cmp r0, r2
    jl .not_in_region
    add r0, r1
    add r2, r3
    cmp r0, r2
    jg .not_in_region
    mov r0, 1
    ret
.not_in_region:
    mov r0, 0
    ret