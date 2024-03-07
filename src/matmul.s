.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 59
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 59
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 59
# =======================================================
matmul:
    # Error checks
    li t0, 1
    blt a1, t0, exception
    blt a2, t0, exception
    blt a4, t0, exception
    blt a5, t0, exception
    bne a2, a4, exception

    # Prologue
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    mv s0, a0  # A
    mv s1, a1
    mv s2, a2
    mv s3, a3  # B
    mv s4, a4
    mv s5, a5
    mv s6, a6  # C

    # C = a1 * a5
    li t0, 0  # row
    li t1, 0  # col

outer_loop_start:
    bge t0, s1, outer_loop_end


inner_loop_start:
    bge t1, s5, inner_loop_end

    mul t2, t0, s2
    slli t2, t2, 2
    add t2, t2, s0
    slli t3, t1, 2
    add t3, t3, s3
    mv a0, t2
    mv a1, t3
    mv a2, s2
    li a3, 1
    mv a4, s5

    # save
    addi sp, sp, -16
    sw t0, 0(sp)
    sw t1, 4(sp)
    sw t2, 8(sp)
    sw t3, 12(sp)
    # call dot
    jal dot
    # restore
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    lw t3, 12(sp)
    addi sp, sp, 16

    # s6[t0][t1] = a0
    mul t2, t0, s5
    add t2, t2, t1
    slli t2, t2, 2
    add t2, t2, s6
    sw a0, 0(t2)

    addi t1, t1, 1
    j inner_loop_start

inner_loop_end:
    addi t0, t0, 1
    xor t1, x0, x0
    j outer_loop_start


outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32

    ret


exception:
    li a1, 59
    call exit2