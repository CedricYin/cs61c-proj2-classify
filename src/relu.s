.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 57
# ==============================================================================
relu:
    li t0, 1
    blt a1, t0, exception

    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)

    mv s0, a0
    mv s1, a1
    xor t0, x0, x0

loop_start:    
    bge t0, s1, loop_end
    slli t1, t0, 2
    add t1, t1, s0
    lw t2, 0(t1)
    bge t2, x0, loop_continue
    sw x0, 0(t1)
    
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