.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 57
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 58
# =======================================================
dot:
    li t0, 1
    blt a2, t0, exception1
    blt a3, t0, exception2
    blt a4, t0, exception2

    # Prologue
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    li s0, 0  # dot procuct
    li s1, 0  # arr1 pointer
    li s2, 0  # arr2 pointer
    li t0, 0  # counter

loop_start:
    bge t0, a2, loop_end

    slli t1, s1, 2
    slli t2, s2, 2
    add t1, t1, a0
    add t2, t2, a1
    lw t1, 0(t1)
    lw t2, 0(t2)

    mul t3, t1, t2
    add s0, s0, t3
    add s1, s1, a3
    add s2, s2, a4
    addi t0, t0, 1
    j loop_start

loop_end:
    mv a0, s0

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12

    ret

exception1:
    li a1, 57
    call exit2

exception2:
    li a1, 58
    call exit2