.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero,
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 72
    # - If malloc fails, this function terminates the program with exit code 88
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    li t0, 5
    bne a0, t0, args_number_wrong

    
    addi sp, sp, -52
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    sw s11, 48(sp)

    mv s0, a0  # argc
    mv s1, a1  # argv
    mv s2, a2  # if 0, then print



	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    li a0, 4
    jal malloc
    beq a0, x0, malloc_fail
    mv s3, a0  # pointer to rows of m0
    li a0 4
    jal malloc
    beq a0, x0, malloc_fail
    mv s4, a0  # pointer to cols of m0
    lw a0, 4(s1)
    mv a1, s3
    mv a2, s4
    jal read_matrix
    mv s5, a0  # pointer to matrix of m0

    # Load pretrained m1
    li a0, 4
    jal malloc
    beq a0, x0, malloc_fail
    mv s6, a0  # pointer to rows of m1
    li a0 4
    jal malloc
    beq a0, x0, malloc_fail
    mv s7, a0  # pointer to cols of m1
    lw a0, 8(s1)
    mv a1, s6
    mv a2, s7
    jal read_matrix
    mv s8, a0  # pointer to matrix of m1 

    # Load input matrix
    li a0, 4
    jal malloc
    beq a0, x0, malloc_fail
    mv s9, a0  # pointer to rows of input
    li a0 4
    jal malloc
    beq a0, x0, malloc_fail
    mv s10, a0  # pointer to cols of input
    lw a0, 12(s1)
    mv a1, s9
    mv a2, s10
    jal read_matrix
    mv s11, a0  # pointer to matrix of input

    # =====================================
    # RUN LAYERS
    # =====================================

    # 1. LINEAR LAYER:    m0 * input
    lw t0, 0(s3)  # rows
    lw t1, 0(s10)  # cols
    mul a0, t0, t1
    slli a0, a0, 2
    jal malloc
    beq a0, x0, malloc_fail
    mv a6, a0
    mv a0, s5
    lw a1, 0(s3)
    lw a2, 0(s4)
    mv a3, s11
    lw a4, 0(s9)
    lw a5, 0(s10)
    addi sp, sp, -4
    sw a6, 0(sp)
    jal matmul
    lw a6, 0(sp)
    addi sp, sp, 4

    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    mv a0, a6
    lw t0, 0(s3)  # rows
    lw t1, 0(s10)  # cols
    mul a1, t0, t1
    addi sp, sp, -4
    sw a6, 0(sp)
    jal relu
    lw a6, 0(sp)
    addi sp, sp, 4

    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    lw t0, 0(s6)
    lw t1, 0(s10)
    mul t2, t1, t0
    slli a0, t2, 2
    addi sp, sp, -4
    mv t5, a6
    sw t5, 0(sp)
    jal malloc
    lw t5, 0(sp)
    addi sp, sp, 4
    beq a0, x0, malloc_fail
    mv t2, a0
    mv a0, s8
    lw a1, 0(s6)
    lw a2, 0(s7)
    mv a3, t5
    lw a4, 0(s3)
    lw a5, 0(s10)
    mv a6, t2
    addi sp, sp, -4
    sw a6, 0(sp)
    jal matmul
    lw a6, 0(sp)
    addi sp, sp, 4
    mv t3, a6  # o = matmul(m1, h)

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0, 16(s1)
    mv a1, t3
    lw a2, 0(s6)
    lw a3, 0(s10)
    addi sp, sp, -8
    sw t3, 0(sp)
    sw t5, 4(sp)
    jal write_matrix
    lw t3, 0(sp)
    lw t5, 4(sp)
    addi sp, sp, 8

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    mv a0, t3
    lw t0, 0(s6)
    lw t1, 0(s10)
    mul a1, t0, t1
    addi sp, sp, -8
    sw t3, 0(sp)
    sw t5, 4(sp)
    jal argmax
    lw t3, 0(sp)
    lw t5, 4(sp)
    addi sp, sp, 8
    mv s0, a0  # return value
    ebreak
    bne s2, x0, end

    # Print classification
    
    mv a1, s0
    addi sp, sp, -8
    sw t3, 0(sp)
    sw t5, 4(sp)
    jal print_int
    lw t3, 0(sp)
    lw t5, 4(sp)
    addi sp, sp, 8

    # Print newline afterwards for clarity
    li a1, '\n'
    addi sp, sp, -8
    sw t3, 0(sp)
    sw t5, 4(sp)
    jal print_char
    lw t3, 0(sp)
    lw t5, 4(sp)
    addi sp, sp, 8

end:
    # free data allocated with malloc
    mv a0, t3
    addi sp, sp, -4
    sw t5, 0(sp)
    jal free
    lw t5, 0(sp)
    addi sp, sp, 4

    mv a0, t5
    jal free

    mv a0, s3
    jal free

    mv a0, s4
    jal free

    mv a0, s5
    jal free

    mv a0, s6
    jal free

    mv a0, s7
    jal free

    mv a0, s8
    jal free

    mv a0, s9
    jal free

    mv a0, s10
    jal free
    
    mv a0, s11
    jal free

    mv a0, s2

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp 52

    
    ret


malloc_fail:
    li a1, 88
    call exit2

args_number_wrong:
    li a1, 72
    call exit2