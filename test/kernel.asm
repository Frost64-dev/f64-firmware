org 0x80000

; r0 = print function
start:
    mov r1, r0
    mov r0, .message
    call r1
    hlt

.message:
    asciiz "Hello from the test kernel!\n"
