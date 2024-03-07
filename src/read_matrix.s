.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 89
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 90
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91
# ==============================================================================
read_matrix:

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

    mv s0, a0  # pointer to filename。file中前两个数字代表row和col
    mv s1, a1  # pointer to row
    mv s2, a2  # pointer to col

    # open file
    mv a1, s0
    li a2, 0
    jal fopen
    li t1, -1
    ebreak
    beq a0, t1, fopen_fail
    mv s3, a0  # file descriptor

    # read row
    mv a1, s3
    mv a2, s1
    li a3, 4
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fread
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a0, a3, fread_fail

    # read col
    mv a1, s3
    mv a2, s2
    li a3, 4
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fread
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a0, a3, fread_fail

    # allocate space on the head for matrix
    lw s4, 0(s1)  # row
    lw s5, 0(s2)  # col
    mul t0, s4, s5
    slli a0, t0, 2
    jal malloc
    beq a0, x0, malloc_fail
    mv s6, a0  # pointer to new space

    # read matrix to the new space
    mv a1, s3
    mv a2, s6
    mul t0, s4, s5
    slli a3, t0, 2
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fread
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a0, a3, fread_fail

    # close file
    mv a1, s3
    jal fclose
    li t0, -1
    beq a0, t0, fclose_fail
    mv a0, s6

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp 32

    ret

malloc_fail:
    # mv a1, s3
    # jal fclose
    # li t0, -1
    # beq a0, t0, fclose_fail

    li a1, 88
    call exit2

fopen_fail:
    li a1, 89
    call exit2

fclose_fail:
    li a1, 90
    call exit2

fread_fail:
    # mv a1, s3
    # jal fclose
    # li t0, -1
    # beq a0, t0, fclose_fail

    li a1, 91
    call exit2