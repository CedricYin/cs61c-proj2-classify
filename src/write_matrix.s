.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 89
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 90
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 92
# ==============================================================================
write_matrix:

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

    mv s0, a0  # pointer to filename
    mv s1, a1  # pointer to matrix
    mv s2, a2  # rows
    mv s3, a3  # cols
    # mv t2, s2  # rows backup
    # mv t3, s3  # cols bakcup

    # open file
    mv a1, s0
    li a2, 1
    jal fopen
    li t1, -1
    beq a0, t1, fopen_fail
    mv s4, a0  # file descriptor

    # store rows on the heap
    li a0, 4
    jal malloc
    beq a0, x0, malloc_fail
    sw s2, 0(a0)
    mv s2, a0  # pointer to rows

    # write rows to file
    mv a1, s4
    mv a2, s2
    li a3, 1
    li a4, 4
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fwrite
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a0, a3, fwrite_fail

    # store cols on the heap
    li a0, 4
    jal malloc
    beq a0, x0, malloc_fail
    sw s3, 0(a0)
    mv s3, a0  # pointer to cols

    # write cols to file
    mv a1, s4
    mv a2, s3
    li a3, 1
    li a4, 4
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fwrite
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a0, a3, fwrite_fail

    # write data
    mv a1, s4
    mv a2, s1
    lw t2, 0(s2)
    lw t3, 0(s3)
    mul a3, t2, t3
    li a4, 4
    addi sp, sp, -4
    sw a3, 0(sp)
    jal fwrite
    lw a3, 0(sp)
    addi sp, sp, 4
    bne a0, a3, fwrite_fail

    # close file
    mv a1, s4
    jal fclose
    bne a0, x0, fclose_fail


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

fwrite_fail:
    # mv a1, s3
    # jal fclose
    # li t0, -1
    # beq a0, t0, fclose_fail

    li a1, 92
    call exit2