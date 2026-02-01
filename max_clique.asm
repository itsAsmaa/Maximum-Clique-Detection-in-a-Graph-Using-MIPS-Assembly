################################################################################
# ENCS4370 - Computer Architecture Project #1
# Maximum Clique Detection in a Graph Using MIPS Assembly
# 
# Description: This program reads a graph from an input file as an adjacency
#              matrix, detects the maximum clique using brute-force approach,
#              and writes the results to an output file.
#
# MODIFIED: Now supports variable-sized matrices from 2×2 to 5×5
#
# Algorithm: Brute-force enumeration
#   1. Generate all possible subsets of vertices (starting from size N to 1)
#   2. For each subset, check if it forms a clique (all pairs connected)
#   3. Keep track of the largest clique found
#   4. Output the maximum clique size and vertices
#
# Input Format: Text file with adjacency matrix
#   - First line: vertex indices (e.g., "0 1 2" for 3×3)
#   - Following lines: row_index followed by N values (0 or 1)
#   - Matrix must be symmetric with 0s on diagonal
#
# Output Format: Text file with results
#   - "Maximum clique size: N"
#   - "Vertices in maximum clique: v1 v2 v3 ..."
#   OR "No clique detected in the graph."
#
# Data Structures:
#   - adjacency_matrix: 5x5 integer array storing graph edges
#   - max_clique_vertices: Array storing vertices in maximum clique
#   - current_subset: Temporary array for testing subsets
#
# Team Members: Asmaa Fares   1210084
#               Aya Fares     1222654
################################################################################

.data
    # ==================== String Constants ====================
    prompt_input:       .asciiz "Enter input file name (press Enter after typing): "
    prompt_output:      .asciiz "Enter output file name (press Enter after typing): "
    reading_file:       .asciiz "Reading file...\n"
    error_file_open:    .asciiz "Error: Cannot open file. Please check the file path.\n"
    error_invalid_matrix: .asciiz "Error: Invalid adjacency matrix format.\nMatrix must be 2x2 to 5x5, symmetric, with 0s on diagonal and only 0/1 values.\n"
    success_message:    .asciiz "Processing complete. Results written to output file.\n"
    newline:            .asciiz "\n"
    space:              .asciiz " "
    
    output_max_size:    .asciiz "Maximum clique size: "
    output_vertices:    .asciiz "Vertices in maximum clique: "
    output_no_clique:   .asciiz "No clique detected in the graph.\n"
    
    # ==================== File Buffers ====================
    input_filename:     .space 256      # Buffer for input filename
    output_filename:    .space 256      # Buffer for output filename
    file_buffer:        .space 1024     # Buffer for reading file content
    
    # ==================== Graph Data Structures ====================
    graph_size:         .word 0         # Number of vertices (2 to 5)
    adjacency_matrix:   .space 100      # 5x5 matrix (25 integers * 4 bytes)
    
    # ==================== Clique Detection Data ====================
    max_clique_size:    .word 0         # Size of maximum clique found
    max_clique_vertices: .space 20      # Array to store vertices in max clique (max 5)
    current_subset:     .space 20       # Current subset being tested
    current_subset_size: .word 0        # Size of current subset
    
    # ==================== File Descriptors ====================
    input_fd:           .word 0         # File descriptor for input file
    output_fd:          .word 0         # File descriptor for output file

.text
.globl main

################################################################################
# Main Program Entry Point
################################################################################
main:
    # Get input filename from user
    li $v0, 4                           # syscall: print string
    la $a0, prompt_input
    syscall
    
    # IMPORTANT: Click in the Run I/O window and type filename
    li $v0, 8                           # syscall: read string
    la $a0, input_filename
    li $a1, 256
    syscall
    
    # Remove newline from input filename
    la $a0, input_filename
    jal remove_newline
    
    # Get output filename from user
    li $v0, 4                           # syscall: print string
    la $a0, prompt_output
    syscall
    
    li $v0, 8                           # syscall: read string
    la $a0, output_filename
    li $a1, 256
    syscall
    
    # Remove newline from output filename
    la $a0, output_filename
    jal remove_newline
    
    # Show we're processing
    li $v0, 4
    la $a0, reading_file
    syscall
    
    # Open and read input file
    jal open_input_file
    beqz $v0, exit_with_error           # If file open failed, exit
    
    jal read_graph_from_file
    beqz $v0, exit_with_error           # If reading failed, exit
    
    jal close_input_file
    
    # Detect maximum clique
    jal find_maximum_clique
    
    # Write results to output file
    jal write_results_to_file
    beqz $v0, exit_with_error           # If writing failed, exit
    
    # Print success message
    li $v0, 4
    la $a0, success_message
    syscall
    
    # Exit program successfully
    li $v0, 10
    syscall

################################################################################
# Exit with error
################################################################################
exit_with_error:
    li $v0, 10                          # syscall: exit
    syscall

################################################################################
# Remove newline character from a string
# Arguments: $a0 = address of string
################################################################################
remove_newline:
    move $t0, $a0                       # Copy string address
remove_newline_loop:
    lb $t1, 0($t0)                      # Load byte
    beqz $t1, remove_newline_done       # If null terminator, done
    li $t2, 10                          # ASCII newline
    beq $t1, $t2, found_newline         # If newline, remove it
    addi $t0, $t0, 1                    # Move to next character
    j remove_newline_loop
found_newline:
    sb $zero, 0($t0)                    # Replace newline with null
remove_newline_done:
    jr $ra

################################################################################
# Open input file for reading
# Returns: $v0 = 1 if successful, 0 if failed
################################################################################
open_input_file:
    li $v0, 13                          # syscall: open file
    la $a0, input_filename              # Filename
    li $a1, 0                           # Flags: read-only
    li $a2, 0                           # Mode: ignored
    syscall
    
    bltz $v0, open_input_failed         # If fd < 0, error
    sw $v0, input_fd                    # Store file descriptor
    li $v0, 1                           # Return success
    jr $ra
    
open_input_failed:
    li $v0, 4
    la $a0, error_file_open
    syscall
    li $v0, 0                           # Return failure
    jr $ra

################################################################################
# Close input file
################################################################################
close_input_file:
    li $v0, 16                          # syscall: close file
    lw $a0, input_fd
    syscall
    jr $ra

################################################################################
# Read graph from file and parse adjacency matrix
# Returns: $v0 = 1 if successful, 0 if failed
################################################################################
read_graph_from_file:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Read file content into buffer
    li $v0, 14                          # syscall: read file
    lw $a0, input_fd
    la $a1, file_buffer
    li $a2, 1024
    syscall
    
    blez $v0, read_failed               # If read <= 0 bytes, error
    
    # Parse the adjacency matrix
    jal parse_adjacency_matrix
    beqz $v0, parse_failed              # If parsing failed, error
    
    # Validate the adjacency matrix
    jal validate_adjacency_matrix
    beqz $v0, validation_failed         # If validation failed, error
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 1                           # Return success
    jr $ra
    
parse_failed:
    li $v0, 4
    la $a0, error_invalid_matrix
    syscall
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 0
    jr $ra
    
validation_failed:
    li $v0, 4
    la $a0, error_invalid_matrix
    syscall
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 0
    jr $ra
    
read_failed:
    li $v0, 4
    la $a0, error_file_open
    syscall
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 0                           # Return failure
    jr $ra

################################################################################
# Parse adjacency matrix from file buffer
# MODIFIED: Now counts vertices from first line to determine matrix size
################################################################################
parse_adjacency_matrix:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $t0, file_buffer                 # Current position in buffer
    li $t1, 0                           # Vertex count
    la $t2, adjacency_matrix            # Matrix storage
    
    # Count vertices in first line to determine matrix size
    li $t1, 0                           # Vertex counter
count_vertices:
    lb $t3, 0($t0)
    beqz $t3, parse_error               # End of file too early
    li $t4, 10                          # Newline character
    beq $t3, $t4, finish_counting       # End of first line
    li $t4, 13                          # Carriage return
    beq $t3, $t4, finish_counting
    
    # Skip whitespace
    li $t4, 32                          # Space
    beq $t3, $t4, count_next_char
    li $t4, 9                           # Tab
    beq $t3, $t4, count_next_char
    
    # Check if it's a digit (vertex index)
    li $t4, 48                          # '0'
    blt $t3, $t4, count_next_char
    li $t4, 57                          # '9'
    bgt $t3, $t4, count_next_char
    
    # Found a vertex, skip the number and count it
    addi $t1, $t1, 1                    # Increment vertex count
skip_number:
    addi $t0, $t0, 1
    lb $t3, 0($t0)
    li $t4, 48
    blt $t3, $t4, count_vertices
    li $t4, 57
    ble $t3, $t4, skip_number
    j count_vertices
    
count_next_char:
    addi $t0, $t0, 1
    j count_vertices
    
finish_counting:
    # Validate vertex count (must be 2-5)
    li $t4, 2
    blt $t1, $t4, parse_error           # Less than 2 vertices
    li $t4, 5
    bgt $t1, $t4, parse_error           # More than 5 vertices
    
    # Store graph size
    sw $t1, graph_size
    
    # Skip to next line
    addi $t0, $t0, 1
    lb $t3, 0($t0)
    li $t4, 10
    beq $t3, $t4, start_matrix_parse
    li $t4, 13
    bne $t3, $t4, start_matrix_parse
    addi $t0, $t0, 1                    # Skip \n after \r
    
start_matrix_parse:
    li $t1, 0                           # Row counter
    lw $t5, graph_size                  # Load N (graph size)
    
parse_matrix_row:
    # Check if we've read N rows
    bge $t1, $t5, parse_matrix_done
    
    # Check for end of file
    lb $t3, 0($t0)
    beqz $t3, parse_matrix_done
    
    # Skip row index and whitespace
    jal skip_row_index
    
    # Read N values for this row
    li $t6, 0                           # Column counter
    
parse_matrix_column:
    # Check if we've read N columns
    lw $t5, graph_size
    bge $t6, $t5, next_matrix_row
    
    # Check for end of line or file
    lb $t3, 0($t0)
    beqz $t3, parse_matrix_done
    li $t4, 10
    beq $t3, $t4, next_matrix_row
    li $t4, 13                          # Carriage return
    beq $t3, $t4, next_matrix_row
    
    # Skip whitespace
    jal skip_whitespace
    
    # Check again after skipping whitespace
    lb $t3, 0($t0)
    beqz $t3, parse_matrix_done
    li $t4, 10
    beq $t3, $t4, next_matrix_row
    
    # Read integer value
    jal read_integer                    # Returns value in $v0
    
    # Store in matrix: matrix[row][col] = value
    # Address = base + (row * 5 + col) * 4
    mul $t7, $t1, 5                     # row * 5 (using max size for storage)
    add $t7, $t7, $t6                   # row * 5 + col
    sll $t7, $t7, 2                     # Multiply by 4 (word size)
    la $t8, adjacency_matrix
    add $t8, $t8, $t7
    sw $v0, 0($t8)                      # Store value
    
    addi $t6, $t6, 1                    # Increment column
    j parse_matrix_column
    
next_matrix_row:
    # Skip to next line
    jal skip_to_newline
    addi $t1, $t1, 1                    # Increment row
    j parse_matrix_row
    
parse_matrix_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 1                           # Return success
    jr $ra
    
parse_error:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 0                           # Return failure
    jr $ra

################################################################################
# Skip row index at beginning of line
################################################################################
skip_row_index:
    lb $t3, 0($t0)
    beqz $t3, skip_row_done
    li $t4, 32                          # Space
    beq $t3, $t4, skip_row_done
    li $t4, 9                           # Tab
    beq $t3, $t4, skip_row_done
    addi $t0, $t0, 1
    j skip_row_index
skip_row_done:
    jr $ra

################################################################################
# Skip to next newline
################################################################################
skip_to_newline:
    lb $t3, 0($t0)
    beqz $t3, skip_nl_done
    li $t4, 10                          # Newline
    beq $t3, $t4, found_nl
    li $t4, 13                          # Carriage return
    beq $t3, $t4, found_nl
    addi $t0, $t0, 1
    j skip_to_newline
found_nl:
    addi $t0, $t0, 1                    # Skip the newline
    # Check for \r\n (Windows line ending)
    lb $t3, 0($t0)
    li $t4, 10
    bne $t3, $t4, skip_nl_done
    addi $t0, $t0, 1                    # Skip \n after \r
skip_nl_done:
    jr $ra

################################################################################
# Validate adjacency matrix
# MODIFIED: Now validates based on actual graph_size instead of fixed 5×5
# Checks: 1) Values are 0 or 1
#         2) Diagonal is all zeros (no self-loops)
#         3) Matrix is symmetric
# Returns: $v0 = 1 if valid, 0 if invalid
################################################################################
validate_adjacency_matrix:
    la $t0, adjacency_matrix
    li $t1, 0                           # Row counter
    lw $t8, graph_size                  # Load N (graph size)
    
validate_row_loop:
    bge $t1, $t8, matrix_valid          # All rows checked
    
    li $t2, 0                           # Column counter
    
validate_col_loop:
    bge $t2, $t8, validate_next_row     # All columns checked
    
    # Get matrix[row][col]
    mul $t3, $t1, 5                     # row * 5 (max storage size)
    add $t3, $t3, $t2                   # row * 5 + col
    sll $t3, $t3, 2                     # * 4
    la $t4, adjacency_matrix
    add $t4, $t4, $t3
    lw $t5, 0($t4)                      # Load value
    
    # Check 1: Value must be 0 or 1
    beqz $t5, check_diagonal            # 0 is valid
    li $t6, 1
    beq $t5, $t6, check_diagonal        # 1 is valid
    j matrix_invalid                    # Any other value is invalid
    
check_diagonal:
    # Check 2: Diagonal must be zero (no self-loops)
    bne $t1, $t2, check_symmetry        # Skip if not diagonal
    bnez $t5, matrix_invalid            # Diagonal must be 0
    
check_symmetry:
    # Check 3: Matrix must be symmetric: matrix[i][j] == matrix[j][i]
    beq $t1, $t2, validate_col_next     # Skip diagonal
    
    # Get matrix[col][row] (transpose position)
    mul $t6, $t2, 5                     # col * 5
    add $t6, $t6, $t1                   # col * 5 + row
    sll $t6, $t6, 2                     # * 4
    la $t7, adjacency_matrix
    add $t7, $t7, $t6
    lw $t9, 0($t7)                      # Load transpose value
    
    bne $t5, $t9, matrix_invalid        # Must be symmetric
    
validate_col_next:
    addi $t2, $t2, 1
    j validate_col_loop
    
validate_next_row:
    addi $t1, $t1, 1
    j validate_row_loop
    
matrix_valid:
    li $v0, 1
    jr $ra
    
matrix_invalid:
    li $v0, 0
    jr $ra

################################################################################
# Skip whitespace characters
################################################################################
skip_whitespace:
    lb $t3, 0($t0)
    beqz $t3, skip_ws_done
    li $t4, 32                          # Space
    beq $t3, $t4, skip_ws_char
    li $t4, 9                           # Tab
    beq $t3, $t4, skip_ws_char
    li $t4, 13                          # Carriage return
    beq $t3, $t4, skip_ws_char
    j skip_ws_done
skip_ws_char:
    addi $t0, $t0, 1
    j skip_whitespace
skip_ws_done:
    jr $ra

################################################################################
# Read integer from buffer
# Returns: $v0 = integer value
################################################################################
read_integer:
    li $v0, 0                           # Result accumulator
    li $t9, 10                          # Multiplier for base 10
    
read_int_loop:
    lb $t3, 0($t0)                      # Load character
    
    # Check if digit (ASCII 48-57)
    li $t4, 48                          # '0'
    blt $t3, $t4, read_int_done
    li $t4, 57                          # '9'
    bgt $t3, $t4, read_int_done
    
    # Convert ASCII to digit and accumulate
    sub $t3, $t3, 48                    # ASCII to digit
    mul $v0, $v0, $t9                   # result *= 10
    add $v0, $v0, $t3                   # result += digit
    
    addi $t0, $t0, 1                    # Next character
    j read_int_loop
    
read_int_done:
    jr $ra

################################################################################
# Find Maximum Clique using brute-force approach
# MODIFIED: Now uses actual graph_size instead of fixed 5
# Strategy: Generate all possible subsets and check if they form a clique
# Note: A clique must have at least 2 vertices (size >= 2)
################################################################################
find_maximum_clique:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Initialize max clique size to 0
    sw $zero, max_clique_size
    
    # Try all possible subset sizes from N down to 2
    lw $s0, graph_size                  # Start with size N
    
try_subset_size:
    li $t9, 2                           # Minimum clique size
    blt $s0, $t9, clique_search_done    # If size < 2, done
    
    # Generate all combinations of size $s0
    move $a0, $s0                       # Subset size to try
    jal generate_and_test_subsets
    
    # If we found a clique of this size, we're done (it's maximum)
    lw $t0, max_clique_size
    bgtz $t0, clique_search_done
    
    addi $s0, $s0, -1                   # Try smaller size
    j try_subset_size
    
clique_search_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

################################################################################
# Generate and test all subsets of given size
# Arguments: $a0 = subset size
################################################################################
generate_and_test_subsets:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0                       # Subset size
    li $s1, 0                           # Current subset index
    la $s2, current_subset              # Subset array
    
    # Use recursive combination generation
    li $a0, 0                           # Start vertex
    li $a1, 0                           # Current position in subset
    move $a2, $s0                       # Target size
    jal generate_combinations_recursive
    
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

################################################################################
# Recursively generate combinations
# MODIFIED: Now uses actual graph_size instead of fixed 5
# Arguments: 
#   $a0 = start vertex
#   $a1 = current position in subset
#   $a2 = target subset size
################################################################################
generate_combinations_recursive:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0                       # Start vertex
    move $s1, $a1                       # Current position
    move $s2, $a2                       # Target size
    
    # Base case: if current position == target size, test this subset
    beq $s1, $s2, test_current_subset
    
    # Recursive case: try adding each remaining vertex
    lw $s3, graph_size                  # Use actual graph size
    
gen_comb_loop:
    bge $s0, $s3, gen_comb_done         # If start >= N, done
    
    # Add vertex $s0 to current subset
    la $t0, current_subset
    sll $t1, $s1, 2                     # Position * 4
    add $t0, $t0, $t1
    sw $s0, 0($t0)                      # Store vertex
    
    # Recurse with next vertex and next position
    addi $a0, $s0, 1                    # Next start vertex
    addi $a1, $s1, 1                    # Next position
    move $a2, $s2                       # Same target size
    jal generate_combinations_recursive
    
    addi $s0, $s0, 1                    # Try next vertex
    j gen_comb_loop
    
test_current_subset:
    # Test if current subset forms a clique
    sw $s2, current_subset_size
    jal check_if_clique                 # Returns $v0 = 1 if clique
    
    beqz $v0, gen_comb_done             # If not a clique, continue
    
    # This is a clique! Check if it's larger than current max
    lw $t0, max_clique_size
    bge $t0, $s2, gen_comb_done         # If current max >= this size, skip
    
    # Update maximum clique
    sw $s2, max_clique_size
    
    # Copy current subset to max_clique_vertices
    la $t0, current_subset
    la $t1, max_clique_vertices
    li $t2, 0
copy_clique_loop:
    bge $t2, $s2, gen_comb_done
    lw $t3, 0($t0)
    sw $t3, 0($t1)
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    j copy_clique_loop
    
gen_comb_done:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra

################################################################################
# Check if current subset forms a clique
# Returns: $v0 = 1 if clique, 0 otherwise
################################################################################
check_if_clique:
    lw $t0, current_subset_size
    la $t1, current_subset
    li $t2, 0                           # Outer loop index
    
check_outer_loop:
    bge $t2, $t0, is_clique             # All pairs checked
    
    li $t3, 0                           # Inner loop index
    
check_inner_loop:
    bge $t3, $t0, check_outer_next
    
    beq $t2, $t3, check_inner_next      # Skip same vertex
    
    # Get vertices i and j
    sll $t4, $t2, 2
    add $t4, $t1, $t4
    lw $t5, 0($t4)                      # Vertex i
    
    sll $t4, $t3, 2
    add $t4, $t1, $t4
    lw $t6, 0($t4)                      # Vertex j
    
    # Check if edge exists: matrix[i][j] == 1
    mul $t7, $t5, 5                     # i * 5
    add $t7, $t7, $t6                   # i * 5 + j
    sll $t7, $t7, 2                     # * 4
    la $t8, adjacency_matrix
    add $t8, $t8, $t7
    lw $t9, 0($t8)                      # Load matrix[i][j]
    
    beqz $t9, not_clique                # If edge doesn't exist, not a clique
    
check_inner_next:
    addi $t3, $t3, 1
    j check_inner_loop
    
check_outer_next:
    addi $t2, $t2, 1
    j check_outer_loop
    
is_clique:
    li $v0, 1
    jr $ra
    
not_clique:
    li $v0, 0
    jr $ra

################################################################################
# Write results to output file
# Returns: $v0 = 1 if successful, 0 if failed
################################################################################
write_results_to_file:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Open output file for writing
    li $v0, 13                          # syscall: open file
    la $a0, output_filename
    li $a1, 1                           # Flags: write-only
    li $a2, 0                           # Mode
    syscall
    
    bltz $v0, write_failed
    move $s0, $v0                       # Save file descriptor
    
    # Check if a clique was found
    lw $t0, max_clique_size
    bgtz $t0, write_clique_found
    
    # No clique found
    li $v0, 15                          # syscall: write file
    move $a0, $s0
    la $a1, output_no_clique
    li $a2, 32                          # Length of message
    syscall
    j write_close_file
    
write_clique_found:
    # Write "Maximum clique size: "
    li $v0, 15
    move $a0, $s0
    la $a1, output_max_size
    li $a2, 21
    syscall
    
    # Write the size
    lw $a1, max_clique_size
    move $a0, $s0
    jal write_integer
    
    # Write newline
    li $v0, 15
    move $a0, $s0
    la $a1, newline
    li $a2, 1
    syscall
    
    # Write "Vertices in maximum clique: "
    li $v0, 15
    move $a0, $s0
    la $a1, output_vertices
    li $a2, 28
    syscall
    
    # Write vertex list
    lw $t0, max_clique_size
    la $t1, max_clique_vertices
    li $t2, 0
    
write_vertex_loop:
    bge $t2, $t0, write_close_file
    
    lw $a1, 0($t1)
    move $a0, $s0
    jal write_integer
    
    # Write space
    li $v0, 15
    move $a0, $s0
    la $a1, space
    li $a2, 1
    syscall
    
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    j write_vertex_loop
    
write_close_file:
    # Write final newline
    li $v0, 15
    move $a0, $s0
    la $a1, newline
    li $a2, 1
    syscall
    
    # Close file
    li $v0, 16
    move $a0, $s0
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 1
    jr $ra
    
write_failed:
    li $v0, 4
    la $a0, error_file_open
    syscall
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    li $v0, 0
    jr $ra

################################################################################
# Write integer to file
# Arguments: $a0 = file descriptor, $a1 = integer value
################################################################################
write_integer:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    move $s0, $a0                       # File descriptor
    move $s1, $a1                       # Integer value
    
    # Convert integer to string (simple approach for single digits)
    addi $s1, $s1, 48                   # Add ASCII '0'
    
    # Store in buffer temporarily
    la $s2, file_buffer
    sb $s1, 0($s2)
    
    # Write to file
    li $v0, 15
    move $a0, $s0
    move $a1, $s2
    li $a2, 1
    syscall
    
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra