.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 57
# =================================================================
argmax:
    ebreak
    li t0, 1
    blt a1, t0, exception

    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)

    mv s0, a0
    mv s1, a1
    li t0, 1
    li a0, 0
    lw a1, 0(s0)


loop_start:
    bge t0, s1, loop_end
    slli t1, t0, 2
    add t1, t1, s0
    lw t2, 0(t1)
    blt t2, a1, loop_continue
    mv a0, t0
    mv a1, t2
    
loop_continue:
    addi t0, t0, 1
    j loop_start

loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8

    ret

exception:
    li a1, 57
    call exit2