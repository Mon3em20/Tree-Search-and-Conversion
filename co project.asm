.data
x:    .word 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
y:    .space 60       # Allocate space for array y (15 integers)
counter: .word 0      # Counter variable
msg_found: .asciiz "\nThe value is found in the array"
msg_not_found: .asciiz "\nThe value is not found in any index"
msg1: .asciiz "\nfrom Representation1 to Representation2 :"
msg2: .asciiz "\nfrom Representation2 to Representation1 :"
space: .asciiz "   "
msg3: .asciiz " \n"

.text
.globl main

# Main Method
main:
    la $a0, x              # load address of x
    la $a1, y              # load address of y
    li $a2, 0              # i = 0
    li $a3, 15             # length = 15 (size of x array)
    jal pro1               # call pro1(x, y, 0, length)

    # Print statement "from Representation1 to Representation2 : " + Arrays.toString(y)
    li $v0, 4              # syscall for print string
    la $a0, msg1           # load address of "from Representation1 to Representation2 : "
    syscall

    # Load address of y and print its content
    
    la $t0, y
    li $t1, 15             # length of y array
print_y:
    beqz $t1, print_y_end  # if length is 0, end loop
    lw $a0, 0($t0)         # load word from y
    li $v0, 1              # syscall for print integer
    syscall
    la $a0, space          # print space between numbers
    li $v0, 4
    syscall
    addi $t0, $t0, 4       # move to next element
    subi $t1, $t1, 1       # decrement length
    j print_y              # repeat
print_y_end:

    la $a0, y              # load address of y
    la $a1, x              # load address of x
    li $a2, 4              # NumberOfLevels = 4
    li $a3, 15             # length = 15
    jal pro2               # call pro2(y, x, NumberOfLevels, length)

    # Print statement "from Representation2 to Representation1 : " + Arrays.toString(x)
    li $v0, 4              # syscall for print string
    la $a0, msg2           # load address of "from Representation2 to Representation1 : "
    syscall

    # Load address of x and print its content
    la $t0, x
    li $t1, 15             # length of x array
print_x:
    beqz $t1, print_x_end  # if length is 0, end loop
    lw $a0, 0($t0)         # load word from x
    li $v0, 1              # syscall for print integer
    syscall
    la $a0, space          # print space between numbers
    li $v0, 4
    syscall
    addi $t0, $t0, 4       # move to next element
    subi $t1, $t1, 1       # decrement length
    j print_x              # repeat
print_x_end:

    la $a0, x              # load address of x
    li $a1, 16            # number to check
    jal check              # call check(x, 300)

    li $v0, 10             # syscall for exit
    syscall

# Procedure 1: pro1
# Arguments: $a0 = address of x, $a1 = address of y, $a2 = i, $a3 = length
pro1:
    bge $a2, $a3, pro1_end # if i >= length, return

    sll $t1, $a2, 2        # t1 = i * 4 (offset for word access)
    add $t1, $t1, $a0      # t1 = &x[i]
    lw $t1, 0($t1)         # t1 = x[i]

    lw $t0, counter        # load counter
    sll $t4, $t0, 2        # t4 = counter * 4
    add $t4, $t4, $a1      # t4 = &y[counter]
    sw $t1, 0($t4)         # y[counter] = x[i]

    addi $t0, $t0, 1       # counter++
    sw $t0, counter

    # Recursive call: pro1(x, y, i * 2 + 1, length)
    addi $sp, $sp, -8      # Adjust stack pointer
    sw $ra, 0($sp)         # Save return address
    sw $a2, 4($sp)         # Save current i

    mul $a2, $a2, 2        # i = i * 2
    addi $a2, $a2, 1       # i = i * 2 + 1
    jal pro1               # Recursive call

    lw $ra, 0($sp)         # Restore return address
    lw $a2, 4($sp)         # Restore i
    addi $sp, $sp, 8       # Restore stack pointer

    # Recursive call: pro1(x, y, i * 2 + 2, length)
    addi $sp, $sp, -8      # Adjust stack pointer
    sw $ra, 0($sp)         # Save return address
    sw $a2, 4($sp)         # Save current i

    mul $a2, $a2, 2        # i = i * 2
    addi $a2, $a2, 2       # i = i * 2 + 2
    jal pro1               # Recursive call

    lw $ra, 0($sp)         # Restore return address
    lw $a2, 4($sp)         # Restore i
    addi $sp, $sp, 8       # Restore stack pointer

pro1_end:
    jr $ra

# Procedure 2: pro2
# Arguments: $a0 = address of x, $a1 = address of y, $a2 = NumberOfLevels, $a3 = length
pro2:
    li $t6, 0              # i = 0
pro2_loop:
    bge $t6, $a2, pro2_end # if i >= NumberOfLevels, return

    lw $t0, counter
    bge $t0, $a3, pro2_inc  # if counter >= length, continue

    sll $t1, $t6, 2        # t1 = i * 4
    add $t2, $a1, $t1      # t2 = &y[i]
    sll $t3, $t0, 2        # t3 = counter * 4
    add $t4, $a0, $t3      # t4 = &x[counter]
    lw $t5, 0($t4)         # t5 = x[counter]
    sw $t5, 0($t2)         # y[i] = x[counter]
    li $t7, -7
    sw $t7, 0($t4)         # x[counter] = -7
    # counter = counter + (2^(NumberOfLevels - i) - 1)
    li $t7, 1
    sub $t8, $a2, $t6      # t8 = NumberOfLevels - i
    sllv $t7, $t7, $t8     # t7 = 2^(NumberOfLevels - i)
    addi $t7, $t7, -1      # t7 = 2^(NumberOfLevels - i) - 1
    add $t0, $t0, $t7
    sw $t0, counter

pro2_inc:
    addi $t6, $t6, 1       # i++
    j pro2_loop            # loop again

pro2_end:
    jr $ra

# Procedure 3: check
# Arguments: $a0 = address of x, $a1 = number
check:
    li $t7, 0              # b = false
    li $t6, 0              # i = 0
check_loop:
    bge $t6, 15, check_end # if i >= length, break loop
    sll $t1, $t6, 2        # t1 = i * 4
    add $t2, $a0, $t1      # t2 = &x[i]
    lw $t0, 0($t2)         # t0 = x[i]
    beq $t0, $a1, check_found # if x[i] == number, b = true
    addi $t6, $t6, 1       # i++
    j check_loop           # loop again

check_found:
    li $t7, 1              # b = true
    j check_end

check_end:
    beqz $t7, print_not_found
    li $v0, 4              # syscall for print string
    la $a0, msg_found      # load address of "The value is found in index"
    syscall
    jr $ra

print_not_found:
    li $v0, 4              # syscall for print string
    la $a0, msg_not_found  # load address of "The value is not found in any index"
    syscall
    jr $ra
