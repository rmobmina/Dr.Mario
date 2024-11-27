####################### CSC258 Assembly Final Project ####################### 
# This file contains our implementation of Dr Mario.
#
# Student 1: Nena Harsch, 1008828789
# Student 2: Reena Obmina, 1009804552
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       2
# - Unit height in pixels:      2
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################

# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
    
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################
# Data for initializing the game.
capsules:                       .space 3168         # Reserve space for 198 possible capsules (198 * 16 bytes per capsule)
next_free_index:                .word 0             # Tracks the next free index in the capsules array for storing new capsules
virus_count:                    .word 4             # The number of viruses in the game    

game_paused:                    .word 0             # Flag indicating if the game is paused (0 = running, 1 = paused)
game_started:                   .word 0             # Flag indicating if the game has started (0 = not started, 1 = started)

# Data for gravity.
gravity_delay:                  .word 500           # Delay value in milliseconds for capsules to move downward
gravity_decrement:              .word 5             # Amount to decrease gravity delay after each cycle
min_gravity_delay:              .word 100           # Minimum gravity delay to ensure lower bound

# Data for the background music.
current_note_index:             .word 0             # Index of the current note being played
note_timer:                     .word 0             # Countdown timer for the duration of the current note

# Data for keeping track of capsule states.
current_capsule_x:              .word 16            # Initial X coordinate for the active capsule
current_capsule_y:              .word 7             # Initial Y coordinate for the active capsule
capsule_orientation:            .word 1             # Orientation of the capsule (1 = vertical, 0 = horizontal)
capsule_top_colour:             .word 0xff0000      # Initial color of the top half of the capsule (red)
capsule_bottom_colour:          .word 0x00ff00      # Initial color of the bottom half of the capsule (green)

next_capsule_x:                 .word 25            # X position for the next capsule
next_capsule_y:                 .word 13            # Y position for the next capsule
next_capsule_top_colour:        .word 0x0000ff      # Initial top color 
next_capsule_bottom_colour:     .word 0xff00ff      # Initial bottom color 
next_capsule_orientation:       .word 1             # Orientation of the next capsule

next_capsule_x1:                .word 25            # X position for the second capsule
next_capsule_y1:                .word 26            # Y position for the second capsule
next_capsule_top_colour1:       .word 0x0000ff      # Initial top color for second capsule
next_capsule_bottom_colour1:    .word 0xff00ff      # Initial bottom color for second capsule

next_capsule_x2:                .word 27            # X position for the third capsule
next_capsule_y2:                .word 26            # Y position for the third capsule
next_capsule_top_colour2:       .word 0x0000ff      # Initial top color for third capsule
next_capsule_bottom_colour2:    .word 0xff00ff      # Initial bottom color for third capsule

next_capsule_x3:                .word 29            # X position for the fourth capsule
next_capsule_y3:                .word 26            # Y position for the fourth capsule
next_capsule_top_colour3:       .word 0x0000ff      # Initial top color for fourth capsule
next_capsule_bottom_colour3:    .word 0xff00ff      # Initial bottom color for fourth capsule

# Data that holds the letters for the pause, game over, and restart screens.
# PAUSED.
P_char:
    .byte 0b1110   
    .byte 0b1001   
    .byte 0b1110   
    .byte 0b1000   
    .byte 0b1000   
    .byte 0b0000   

A_char:
    .byte 0b0110   
    .byte 0b1001   
    .byte 0b1111   
    .byte 0b1001   
    .byte 0b1001   
    .byte 0b0000   

U_char:
    .byte 0b1001   
    .byte 0b1001   
    .byte 0b1001   
    .byte 0b1001   
    .byte 0b0110   
    .byte 0b0000   

S_char:
    .byte 0b0111  
    .byte 0b1000   
    .byte 0b0110   
    .byte 0b0001   
    .byte 0b1110   
    .byte 0b0000   

E_char:
    .byte 0b1111  
    .byte 0b1000  
    .byte 0b1111 
    .byte 0b1000  
    .byte 0b1111   
    .byte 0b0000  

D_char:
    .byte 0b1110  
    .byte 0b1001  
    .byte 0b1001  
    .byte 0b1001  
    .byte 0b1110  
    .byte 0b0000  
    
# GAME OVER.
G1_char:
    .byte 0b01110  
    .byte 0b10000   
    .byte 0b10110   
    .byte 0b10010   
    .byte 0b01110  
    .byte 0b00000  

A1_char:
    .byte 0b01110   
    .byte 0b10001  
    .byte 0b11111  
    .byte 0b10001  
    .byte 0b10001   
    .byte 0b00000  

M1_char:
    .byte 0b10001   
    .byte 0b11011   
    .byte 0b10101   
    .byte 0b10001   
    .byte 0b10001   
    .byte 0b00000   

E1_char:
    .byte 0b11111  
    .byte 0b10000  
    .byte 0b11110   
    .byte 0b10000   
    .byte 0b11111   
    .byte 0b00000  

O1_char:
    .byte 0b01110  
    .byte 0b10001  
    .byte 0b10001   
    .byte 0b10001  
    .byte 0b01110   
    .byte 0b00000   

V1_char:
    .byte 0b10001  
    .byte 0b10001   
    .byte 0b01010   
    .byte 0b01010   
    .byte 0b00100   
    .byte 0b00000   

R1_char:
    .byte 0b11110   
    .byte 0b10001   
    .byte 0b11110   
    .byte 0b10100   
    .byte 0b10010   
    .byte 0b00000  

# RESTART.
P3_char:
    .byte 0b1110  
    .byte 0b1001   
    .byte 0b1110  
    .byte 0b1000   
    .byte 0b1000  
    .byte 0b0000   

T3_char:
    .byte 0b111  
    .byte 0b010   
    .byte 0b010 
    .byte 0b010 
    .byte 0b010  
    .byte 0b000  

R3_char:
    .byte 0b110   
    .byte 0b101  
    .byte 0b110   
    .byte 0b101  
    .byte 0b101   
    .byte 0b000   

E3_char:
    .byte 0b111 
    .byte 0b100   
    .byte 0b111   
    .byte 0b100 
    .byte 0b111  
    .byte 0b000   

S3_char:
    .byte 0b011  
    .byte 0b100   
    .byte 0b011  
    .byte 0b001   
    .byte 0b110  
    .byte 0b000  

A3_char:
    .byte 0b010   
    .byte 0b101  
    .byte 0b111   
    .byte 0b101  
    .byte 0b101   
    .byte 0b000   

# Data for the background music score.
# Parameters are pitch, duration, instrument, volume.
# Music score from musescore.com.
.align 2
music_score:
    .word 31, 40, 87, 70  
    .word 31, 40, 87, 80  
    .word 34, 40, 87, 20  
    .word 35, 40, 87, 20
    .word 36, 40, 87, 20
    .word 35, 40, 87, 20
    .word 34, 40, 87, 20
    .word 33, 40, 87, 20
    .word 31, 40, 87, 80  
    .word 31, 40, 87, 80   
    .word 34, 40, 87, 30  
    .word 35, 40, 87, 30
    .word 36, 40, 87, 30
    .word 35, 40, 87, 30
    .word 34, 40, 87, 30
    .word 33, 40, 87, 30
    .word 31, 40, 87, 90   
    .word 31, 40, 87, 90  
    .word 34, 40, 87, 40 
    .word 35, 40, 87, 40
    .word 36, 40, 87, 40
    .word 35, 40, 87, 40
    .word 34, 40, 87, 40
    .word 33, 40, 87, 40
    .word 31, 40, 87, 100  
    .word 31, 40, 87, 100 
    .word 34, 40, 87, 50  
    .word 35, 40, 87, 50
    .word 36, 40, 87, 50
    .word 35, 40, 87, 50
    .word 34, 40, 87, 50
    .word 33, 40, 87, 50
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 57, 40, 86, 70
    .word 55, 40, 86, 70
    .word 55, 40, 86, 70
    .word 57, 40, 86, 70
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 57, 40, 86, 70
    .word 55, 40, 86, 70
    .word 55, 640, 86, 70
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 57, 40, 86, 70
    .word 55, 40, 86, 70
    .word 55, 40, 86, 70
    .word 57, 40, 86, 70
    .word 71, 10, 100, 90
    .word 71, 10, 100, 90
    .word 71, 20, 100, 70
    .word 72, 10, 100, 90
    .word 72, 10, 100, 90
    .word 72, 20, 100, 70
    .word 73, 10, 100, 90
    .word 73, 10, 100, 90
    .word 73, 20, 100, 70
    .word 74, 10, 100, 70
    .word 74, 10, 100, 80
    .word 74, 20, 100, 90
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 57, 40, 86, 70
    .word 55, 40, 86, 70
    .word 55, 40, 86, 70
    .word 57, 40, 86, 70
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 57, 40, 86, 70
    .word 55, 40, 86, 70
    .word 55, 640, 86, 70
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 58, 40, 86, 70
    .word 59, 40, 86, 70
    .word 57, 40, 86, 70
    .word 55, 40, 86, 70
    .word 55, 40, 86, 70
    .word 57, 40, 86, 70
    .word 92, 10, 99, 70
    .word 86, 10, 99, 70
    .word 83, 20, 99, 70
    .word 73, 10, 99, 70
    .word 82, 20, 99, 70
    .word 99, 10, 99, 70
    .word 92, 10, 99, 70
    .word 88, 10, 99, 70 
    .word 86, 10, 99, 70
    .word 75, 10, 99, 70
    .word 73, 10, 99, 70
    .word 71, 10, 99, 70
    .word 70, 10, 99, 70
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 40, 86, 70
    .word 45, 40, 86, 70
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 640, 86, 70
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 40, 86, 70
    .word 45, 40, 86, 70
    .word 42, 40, 86, 70
    .word 45, 40, 86, 70
    .word 47, 40, 86, 70
    .word 50, 40, 86, 70
    .word 60, 40, 86, 70
    .word 55, 40, 86, 70
    .word 59, 40, 86, 70
    .word 55, 40, 86, 70
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 320, 86, 70
    .word 29, 40, 96, 100
    .word 29, 120, 96, 0
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 320, 86, 70
    .word 29, 40, 96, 100
    .word 29, 120, 96, 0
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 40, 86, 70
    .word 45, 40, 86, 70
    .word 60, 40, 86, 100
    .word 55, 40, 86, 70
    .word 62, 40, 86, 100
    .word 55, 40, 86, 70
    .word 60, 320, 86, 100
    .word 76, 800, 46, 60
    .word 74, 400, 46, 60
    .word 79, 400, 46, 70
    .word 72, 800, 46, 60
    .word 60, 800, 46, 40
    .word 81, 800, 46, 60
    .word 79, 400, 46, 60
    .word 84, 400, 46, 70
    .word 77, 800, 46, 60
    .word 65, 800, 46, 40
    .word 76, 800, 46, 80
    .word 74, 400, 46, 80
    .word 79, 400, 46, 90
    .word 72, 800, 46, 80
    .word 60, 800, 46, 60
    .word 81, 800, 46, 80
    .word 79, 400, 46, 80
    .word 83, 400, 46, 90
    .word 84, 800, 46, 100
    .word 84, 800, 46, 60
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 320, 86, 70
    .word 29, 40, 96, 100
    .word 29, 120, 96, 0
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 320, 86, 70
    .word 29, 40, 96, 100
    .word 29, 120, 96, 0
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 51, 40, 86, 70
    .word 52, 40, 86, 70
    .word 50, 40, 86, 70
    .word 48, 40, 86, 70
    .word 48, 40, 86, 70
    .word 45, 40, 86, 70
    .word 60, 40, 86, 100
    .word 55, 40, 86, 70
    .word 62, 40, 86, 100
    .word 55, 40, 86, 70
    .word 60, 320, 86, 100
    .word 36, 320, 87, 100
    .word 0                

##############################################################################
# Code
##############################################################################
	.text
	.globl main

# Run the game.
main:
    sw $zero, next_free_index               # Initialize the next_free_index variable to 0 (no capsules used yet)
    
    initialize_capsules:                    # Label for initializing the capsules array
    la $t0, capsules                        # Load base address of capsules array
    li $t1, 1584                            # Total size of the array in bytes (8 capsules * 12 bytes each)
    li $t2, 0                               # Prepare a zero value in $t2 to initialize the array)

    init_loop:
    beqz $t1, reset_bitmap                  # Exit the loop when the entire array is initialized
    sw $t2, 0($t0)                          # Store 0 at the current address
    addiu $t0, $t0, 4                       # Move to the next word (4 bytes)
    subiu $t1, $t1, 4                       # Decrease size counter by 4 bytes
    j init_loop                             # Repeat the loop
    
    reset_bitmap:                           # Label for resetting the display bitmap memory
    lw $t0, ADDR_DSPL                       # Address of the bitmap memory
    li $t1, 0                               # Initialize to zero
    li $t2, 4096                            # Size of the bitmap (32x32 pixels = 1024 bytes * 4)
    
    reset_loop:                             # Start of the loop to reset the bitmap memory
    sw $t1, 0($t0)                          # Clear one word
    addiu $t0, $t0, 4                       # Move to next word
    subi $t2, $t2, 4                        # Decrease size
    bgtz $t2, reset_loop                    # Repeat until bitmap is cleared
    
    reset_variables:                        # Label for resetting game variables to their initial state
    li $t0, 4                               # Load the initial virus count into $t0
    sw $t0, virus_count                     # Store the initial virus count
    sw $zero, game_started                  # Set game_started to 0 (game not started yet)
    li $t0, 500                             # Load the initial gravity delay (500ms) into $t0
    sw $t0, gravity_delay                   # Store the gravity delay
    li $t0, 5                               # Load the gravity decrement value into $t0
    sw $t0, gravity_decrement               # Store the gravity decrement value
    li $t0, 100                             # Load the minimum gravity delay value into $t0
    sw $t0, min_gravity_delay               # Store the minimum gravity delay
    sw $zero, game_paused                   # Set game_paused to 0 (game is not paused)
    sw $zero, current_note_index            # Initialize the current_note_index to 0
    sw $zero, note_timer                    # Initialize the note_timer to 0
    
    # Drawings for Dr. Mario and Viruses on the sides.
    # Dr. Mario.
    # Load colors into registers for Dr. Mario.
    li $t1, 0xffb56c                        # SKIN color
    li $t2, 0x964b00                        # HAIR color
    li $t3, 0xacacac                        # GREY color
    li $t4, 0xffffff                        # WHITE color
    li $t5, 0x000000                        # BLACK color 

    lw $t0, ADDR_DSPL                       # Load base address for display
    addi $t6, $t0, 2148                     # 16 * 128 + 25 * 4

    sw $t1, 0($t6)           
    sw $t5, 4($t6)           
    sw $t3, 8($t6)           
    sw $t2, 12($t6)          
    sw $t2, 16($t6)          
    addi $t6, $t6, 128        
    sw $t4, 0($t6)          
    sw $t1, 4($t6)           
    sw $t5, 8($t6)           
    sw $t1, 12($t6)          
    sw $t1, 16($t6)          
    addi $t6, $t6, 128        
    sw $t4, 0($t6)           
    sw $t5, 4($t6)           
    sw $t1, 8($t6)           
    sw $t1, 12($t6)          
    sw $t2, 16($t6)          
    addi $t6, $t6, 128        
    sw $t4, 0($t6)           
    sw $t4, 4($t6)           
    sw $t3, 8($t6)           
    sw $t4, 12($t6)          
    sw $t5, 16($t6)          
    addi $t6, $t6, 128        
    sw $t5, 0($t6)          
    sw $t4, 4($t6)           
    sw $t3, 8($t6)           
    sw $t4, 12($t6)          
    sw $t4, 16($t6)          
    addi $t6, $t6, 128      
    sw $t5, 0($t6)          
    sw $t4, 4($t6)          
    sw $t4, 8($t6)         
    sw $t4, 12($t6)         
    sw $t4, 16($t6)         
    addi $t6, $t6, 128        
    sw $t5, 0($t6)          
    sw $t4, 4($t6)         
    sw $t4, 8($t6)           
    sw $t4, 12($t6)          
    sw $t1, 16($t6)         
    addi $t6, $t6, 128        
    sw $t5, 0($t6)          
    sw $t4, 4($t6)          
    sw $t5, 8($t6)          
    sw $t4, 12($t6)          
    sw $t5, 16($t6)         
    addi $t6, $t6, 128       
    sw $t2, 0($t6)           
    sw $t2, 4($t6)          
    sw $t5, 8($t6)         
    sw $t2, 12($t6)         
    sw $t2, 16($t6)         
    addi $t6, $t6, 128    

    # Viruses.
    # Load colors into registers for viruses.
    li $t1, 0x00ff00                        # GREEN virus color
    li $t2, 0xff0000                        # RED virus color
    li $t3, 0x0000ff                        # BLUE virus color

    lw $t0, ADDR_DSPL                       # Load base address for display
    li $t6, 1160                            # 8 * 128 + 1 * 4

    # GREEN.
    add $t7, $t0, $t6       
    sw $t1, 0($t7)         
    sw $t1, 4($t7)        
    sw $t1, 12($t7)         
    sw $t1, 16($t7)       
    sw $t1, 132($t7)          
    sw $t1, 136($t7)        
    sw $t1, 140($t7)         
    sw $t1, 256($t7)         
    sw $t1, 260($t7)         
    sw $t1, 264($t7)          
    sw $t1, 268($t7)        
    sw $t1, 272($t7)         
    sw $t1, 388($t7)          
    sw $t1, 392($t7)          
    sw $t1, 396($t7)         
    sw $t1, 512($t7)         
    sw $t1, 516($t7)          
    sw $t1, 524($t7)         
    sw $t1, 528($t7)         

    # RED.
    addi $t7, $t7, 896       
    sw $t2, 0($t7)          
    sw $t2, 4($t7)          
    sw $t2, 12($t7)          
    sw $t2, 16($t7)          
    sw $t2, 132($t7)         
    sw $t2, 136($t7)          
    sw $t2, 140($t7)        
    sw $t2, 256($t7)           
    sw $t2, 260($t7)           
    sw $t2, 264($t7)           
    sw $t2, 268($t7)         
    sw $t2, 272($t7)         
    sw $t2, 388($t7)          
    sw $t2, 392($t7)         
    sw $t2, 396($t7)         
    sw $t2, 512($t7)          
    sw $t2, 516($t7)           
    sw $t2, 524($t7)         
    sw $t2, 528($t7)         
    
    # BLUE.
    addi $t7, $t7, 896       
    sw $t3, 0($t7)          
    sw $t3, 4($t7)          
    sw $t3, 12($t7)          
    sw $t3, 16($t7)         
    sw $t3, 132($t7)          
    sw $t3, 136($t7)         
    sw $t3, 140($t7)        
    sw $t3, 256($t7)          
    sw $t3, 260($t7)          
    sw $t3, 264($t7)          
    sw $t3, 268($t7)          
    sw $t3, 272($t7)         
    sw $t3, 388($t7)         
    sw $t3, 392($t7)         
    sw $t3, 396($t7)         
    sw $t3, 512($t7)          
    sw $t3, 516($t7)          
    sw $t3, 524($t7)        
    sw $t3, 528($t7)         

    # This is the code used to draw the bottle.
    # It uses registers $a0, $a1, and $a2 to pass the X and Y coordinates to the functions draw_horizontal and draw_vertical.
    addi $a0, $zero, 14                     # Set the X coordinate
    addi $a1, $zero, 7                      # Set the Y coordinate
    addi $a2, $zero, 2                      # Set the len of line
    jal draw_vertical
    
    addi $a0, $zero, 18                     # Set the X coordinate
    addi $a1, $zero, 7                      # Set the Y coordinate
    addi $a2, $zero, 2                      # Set the len of line
    jal draw_vertical
    
    addi $a0, $zero, 10                     # Set the X coordinate
    addi $a1, $zero, 9                      # Set the Y coordinate
    addi $a2, $zero, 5                      # Set the len of line
    jal draw_horizontal
    
    addi $a0, $zero, 18                     # Set the X coordinate
    addi $a1, $zero, 9                      # Set the Y coordinate
    addi $a2, $zero, 5                      # Set the len of line
    jal draw_horizontal
    
    addi $a0, $zero, 10                     # Set the X coordinate
    addi $a1, $zero, 9                      # Set the Y coordinate
    addi $a2, $zero, 20                     # Set the len of line
    jal draw_vertical
    
    addi $a0, $zero, 22                     # Set the X coordinate
    addi $a1, $zero, 9                      # Set the Y coordinate
    addi $a2, $zero, 20                     # Set the len of line
    jal draw_vertical
    
    addi $a0, $zero, 10                     # Set the X coordinate
    addi $a1, $zero, 28                     # Set the Y coordinate
    addi $a2, $zero, 12                     # Set the len of line
    jal draw_horizontal
    
    addi $a0, $zero, 13                     # Set the X coordinate
    addi $a1, $zero, 7                      # Set the Y coordinate
    addi $a2, $zero, 2                      # Set the len of line
    jal draw_horizontal
    
    addi $a0, $zero, 18                     # Set the X coordinate
    addi $a1, $zero, 7                      # Set the Y coordinate
    addi $a2, $zero, 2                      # Set the len of line
    jal draw_horizontal
    
    # Initialize the capsule state at the start of the game.
    # This sets the capsule's position, orientation, and random colors.
    jal init_capsule_state
    jal draw_capsule
    jal draw_next_capsule
    jal draw_next_capsule1
    jal draw_next_capsule2
    jal draw_next_capsule3
    
    # Draw viruses.
    # $t0 stores the number of viruses drawn.
    # $t1 stores the max number of viruses.
    add $t0, $zero, $zero                   # Number of viruses drawn
    
    draw_virus: 
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t0, 0 ($sp)                     # Push $t0 onto the stack
        jal random_virus
        lw $t0, 0 ($sp)                     # Pop the $t0 off the stack 
        addi $sp, $sp, 4                    # Move the stack pointer
        
        lw $t1, virus_count
        addi $t0, $t0, 1                    # Increment virus count
        beq $t0, $t1, draw_virus_end
        j draw_virus
    draw_virus_end:
        j game_loop
    
    
# Procedure to play a sound using the MIDI system call.
# $a0 = pitch (0-127)
# $a1 = duration (in milliseconds)
# $a2 = instrument (0-127)
# $a3 = volume (0-127)
play_sound:
    li $v0, 31                              # Syscall for MIDI output
    syscall
    jr $ra                                  # Return to the caller

draw_character:
    lw $t0, ADDR_DSPL                       # Base address of the display
    move $t1, $a0                           # Starting X-coordinate
    move $t2, $a1                           # Starting Y-coordinate
    move $t3, $a2                           # Color
    move $t4, $a3                           # Address of character bitmap
    li $t5, 5                               # Height of the character (5 rows)

draw_char_loop:
    lb $t6, 0($t4)                          # Load a row of the character bitmap (byte-oriented access)
    beqz $t5, char_done                     # If height is 0, we're done
    li $t7, 5                               # Width of the character (5 columns)
    move $t8, $t1                           # Reset X for each row

draw_pixel_loop:
    srl $t9, $t6, 4                         # Shift leftmost bit to position 0
    andi $t9, $t9, 1                        # Mask to isolate the leftmost bit
    beqz $t9, skip_pixel                    # Skip if the bit is 0

    # Calculate pixel address
    move $s0, $t8                           # Temporarily store current X
    sll $s0, $s0, 2                         # Scale X by 4
    sll $s1, $t2, 7                         # Scale Y by 128
    add $s2, $t0, $s0                       # Base + X
    add $s2, $s2, $s1                       # Base + Y
    sw $t3, 0($s2)                          # Write color to pixel

skip_pixel:
    sll $t6, $t6, 1                         # Shift to the next bit in the row
    addi $t8, $t8, 1                        # Increment X
    subi $t7, $t7, 1                        # Decrement column counter
    bnez $t7, draw_pixel_loop               # Continue until row is complete

    addi $t4, $t4, 1                        # Move to the next row of the character
    addi $t2, $t2, 1                        # Increment Y for the next row
    subi $t5, $t5, 1                        # Decrement row counter
    j draw_char_loop

char_done:
    jr $ra

draw_paused_message:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $a0, 1                               # Starting X-coordinate
    li $a1, 1                               # Starting Y-coordinate
    li $a2, 0xffffff                        # Colour (white)

    # Draw each letter of "PAUSED" with a space
    la $a3, P_char             
    jal draw_character
    addi $a0, $a0, 5          
    la $a3, A_char            
    jal draw_character
    addi $a0, $a0, 5          
    la $a3, U_char             
    jal draw_character
    addi $a0, $a0, 5          
    la $a3, S_char            
    jal draw_character
    addi $a0, $a0, 5         
    la $a3, E_char            
    jal draw_character
    addi $a0, $a0, 5        
    la $a3, D_char            
    jal draw_character
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra                     


# Clear the screen by setting all pixels to black.
clear_screen:
    lw $t0, ADDR_DSPL                       # Load the base address of the display
    li $t1, 0x000000                        # Black colour
    li $t2, 0                               # Start index

clear_loop:
    sw $t1, 0($t0)                          # Set pixel to black
    addi $t0, $t0, 4                        # Move to the next pixel
    addi $t2, $t2, 1                        # Increment pixel counter
    li $t3, 4096                            # Total number of pixels (64 * 64 = 4096)
    bne $t2, $t3, clear_loop                # Continue until all pixels are cleared
    jr $ra                                  

# Draw the "GAME OVER" message on the black screen.
draw_game_over_message:
    addi $sp, $sp, -4
    sw $ra, 0 ($sp)
    
    # Clear the screen first.
    jal clear_screen

    li $a0, 4                               # Starting X-coordinate for "GAME"
    li $a1, 3                               # Starting Y-coordinate for "GAME"
    li $a2, 0xff0000                        # Red color
    
    # Draw "GAME" on the first row.
    la $a3, G1_char             
    jal draw_character
    addi $a0, $a0, 6            
    la $a3, A1_char            
    jal draw_character
    addi $a0, $a0, 6           
    la $a3, M1_char           
    jal draw_character
    addi $a0, $a0, 6           
    la $a3, E1_char             
    jal draw_character

    # Draw "OVER" on the second row.
    li $a0, 4                               # Starting X-coordinate for "OVER"
    li $a1, 10                              # Starting Y-coordinate for "OVER"
    la $a3, O1_char             
    jal draw_character
    addi $a0, $a0, 6           
    la $a3, V1_char             
    jal draw_character
    addi $a0, $a0, 6           
    la $a3, E1_char            
    jal draw_character
    addi $a0, $a0, 6           
    la $a3, R1_char           
    jal draw_character
    
    # Draw "Press R Restart" below.
    jal draw_restart_message
    lw $ra, 0 ($sp)
    addi $sp, $sp, 4
    jr $ra                                    

# Draw the "Press R Restart" message on the game over screen.
draw_restart_message:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Draw "PRESS R" on the first line.
    li $a0, 1                               # Starting X-coordinate
    li $a1, 17                              # Starting Y-coordinate
    li $a2, 0xffffff                        # White color

    la $a3, P3_char       
    jal draw_character
    addi $a0, $a0, 4       
    la $a3, R3_char        
    jal draw_character
    addi $a0, $a0, 4       
    la $a3, E3_char        
    jal draw_character
    addi $a0, $a0, 5        
    la $a3, S_char         
    jal draw_character
    addi $a0, $a0, 5       
    la $a3, S_char          
    jal draw_character
    addi $a0, $a0, 5       
    la $a3, R3_char        
    jal draw_character

    # Move to the second line for "TO RESTART."
    li $a0, 0                               # Reset X-coordinate (centered horizontally)
    li $a1, 23                              # Set Y-coordinate for the second line

    la $a3, R3_char         
    jal draw_character
    addi $a0, $a0, 4       
    la $a3, E3_char         
    jal draw_character
    addi $a0, $a0, 4       
    la $a3, S3_char         
    jal draw_character
    addi $a0, $a0, 4       
    la $a3, T3_char         
    jal draw_character
    addi $a0, $a0, 4       
    la $a3, A3_char          
    jal draw_character
    addi $a0, $a0, 4       
    la $a3, R3_char        
    jal draw_character
    addi $a0, $a0, 4      
    la $a3, T3_char         
    jal draw_character

    # Restore the stack and return.
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


# This is the code to draw a horizontal line.
# $a0 is the X offset.
# $a1 is the Y offset.
# $a2 is the length of the line.
# $t0 stores the location of the bitmap.
# $t1 stores color grey for the outline.
# $t2 stores the location of the calculated X and Y offset in relation to the bitmap.
# $t3 stores the location of the calculated endpoint in relation to the bitmap.
draw_horizontal:
    li $t1, 0x808080                        # Set the color of the line (grey)
    lw $t0, ADDR_DSPL                       # Store the top left of the bitmap in $t0
    sll $a0, $a0, 2                         # Calculate the X offset to add to $t0
    sll $a1, $a1, 7                         # Calculate the Y offset to add to $t0 
    add $t2, $t0, $zero                     # Initialize $t2 with $t0
    add $t2, $t2, $a0                       # Add X offset to $t2
    add $t2, $t2, $a1                       # Add Y offset to $t2
    sll $a2, $a2, 2                         # Calculate the final point of the line
    add $t3, $t2, $a2                       # Add the final point to $t3

    horizontal_line_start:
        sw $t1, 0( $t2 )                    # Draw a pixel at the current location of the bitmap
        addi $t2, $t2, 4                    # Go to the next pixel (aka +4)
        beq $t2, $t3, horizontal_line_end   # Break out of the loop when $t2 == $t3
        j horizontal_line_start
    horizontal_line_end:
    
    jr $ra                                  # Return to calling program 
 

# This is the code to draw a vertical line.
# $a0 is the X offset.
# $a1 is the Y offset.
# $a2 is the length of the line.
# $t0 stores the location of the bitmap.
# $t1 stores color grey for the outline.
# $t2 stores the location of the calculated X and Y offset in relation to the bitmap.
# $t3 stores the location of the calculated endpoint in relation to the bitmap.
draw_vertical:
    li $t1, 0x808080                        # Set the color of the line (grey)
    lw $t0, ADDR_DSPL                       # Store the top left of the bitmap in $t0
    sll $a0, $a0, 2                         # Calculate the X offset 
    sll $a1, $a1, 7                         # Calculate the Y offset
    add $t2, $t0, $zero                     # Initialize $t2 with $t0
    add $t2, $t2, $a0                       # Add X offset to $t2
    add $t2, $t2, $a1                       # Add Y offset to $t2
    sll $a2, $a2, 7                         # Calculate the final point of the line (mult by 128 or shift 7)
    add $t3, $t2, $a2                       # Add the final point to $t3

    vertical_line_start:
        sw $t1, 0( $t2 )                    # Draw a pixel at the current location of the bitmap
        addi $t2, $t2, 128                  # Go to the next pixel (aka +128)
        beq $t2, $t3, vertical_line_end     # Break out of the loop when $t2 == $t3
        j vertical_line_start
    vertical_line_end:

    jr $ra                                  # Return to calling program 


# This section initializes the location and the colors of the capsule at the top.
# $t0 is used temporarily throughout the code to initialize values into the mutable varaiables.
# Stack is used to generate the random colors.
init_capsule_state:
    # Initialize the current capsule's position and orientation
    li $t0, 16                              # Default X position for the capsule
    sw $t0, current_capsule_x               # Store in current_capsule_x
    li $t0, 7                               # Default Y position for the capsule
    sw $t0, current_capsule_y               # Store in current_capsule_y
    li $t0, 1                               # Vertical orientation
    sw $t0, capsule_orientation             # Store in capsule_orientation

    # Initialize the current capsule's colors
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Save $ra on the stack

    jal random_colour                       # Generate a random color
    lw $t0, 0($sp)                          # Retrieve the random color
    addi $sp, $sp, 4                        # Restore the stack pointer
    sw $t0, capsule_top_colour              # Store in capsule_top_colour

    jal random_colour                       # Generate another random color
    lw $t0, 0($sp)                          # Retrieve the random color
    addi $sp, $sp, 4                        # Restore the stack pointer
    sw $t0, capsule_bottom_colour           # Store in capsule_bottom_colour

    # Restore $ra and return
    lw $ra, 0($sp)                          # Retrieve $ra from the stack
    addi $sp, $sp, 4                        # Restore the stack pointer
    jr $ra                                  # Return to the caller


# This function generates a random color and sends back the value for that color.
# $a0, $a1, and $v0 are used for the syscall to generate a random number between 0-2.
# $t5 stores a constant 1.
# $t6 stores Green, Red, or Blue.
# Stack is used to send back the color.
random_colour:
    li $v0 , 42                             # Random generator with max
    li $a0 , 0                              # Where the random number is stored
    li $a1 , 3                              # Max random number (0-2)
    syscall
    addi $t5, $zero, 1                      # Store constant 1
    beq $a0, $zero, RED
    beq $a0, $t5, BLUE
GREEN:
    addi $sp, $sp, -4                       # Move the stack pointer
    li $t6, 0x00ff00                        # Store Green
    sw $t6, 0 ($sp)                         # Push onto stack
    j done_random_colour
RED:
    addi $sp, $sp, -4                       # Move the stack pointer
    li $t6, 0xff0000                        # Store Red
    sw $t6, 0 ($sp)                         # Push onto stack
    j done_random_colour
BLUE:
    addi $sp, $sp, -4                       # Move the stack pointer
    li $t6, 0x0000ff                        # Store Blue
    sw $t6, 0 ($sp)                         # Push onto stack
done_random_colour:
    jr $ra


# This code is used to draw the capsule.
# $t0 is used to store the X direction of the capsule.
# $t1 is used to store the Y direction of the capsule.
# $t2 is used to store the bitmap address.
# $t3 is used to store the top capsule color.
# $t4 is used to store the bottom capsule color.
# $t5 is used to store the calculated top/ bottom capsule location.
draw_capsule:
    # Load coordinates of capsule.
    lw $t0, current_capsule_x
    lw $t1, current_capsule_y
    lw $t2, ADDR_DSPL

    lw $t3, capsule_top_colour              # Color for top 
    lw $t4, capsule_bottom_colour           # Color for bottom 
    
    # Calculate capsule position.
    sll $t0, $t0, 2                         # Scale X
    sll $t1, $t1, 7                         # Scale Y
    add $t5, $t2, $t0                       # Base address + X offset
    add $t5, $t5, $t1                       # Base address + Y offset
    sw $t3, 0($t5)                          # Paint the top capsule
    lw $t6, capsule_orientation
    beq $t6, $zero, horizontal_draw
    addi $t5, $t5, 128                      # Find the coordinates of the bottom capsule
    j end_calculation
    horizontal_draw:
    addi $t5, $t5, 4
    end_calculation:
    sw $t4, 0($t5)                          # Paint the bottom capsule
    
    jr $ra
    

draw_next_capsule:
    # Load the display address.
    lw $t0, ADDR_DSPL

    # Load the next capsule's position.
    lw $t1, next_capsule_x                # X position
    lw $t2, next_capsule_y                # Y position

    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Load the next capsule's colours.
    jal random_colour                       # Generate a random color
    lw $t7, 0($sp)                          # Retrieve the random color
    addi $sp, $sp, 4                        # Restore the stack pointer
    sw $t7, next_capsule_top_colour         # Store in next_capsule_top_colour

    jal random_colour                       # Generate another random color
    lw $t7, 0($sp)                          # Retrieve the random color
    addi $sp, $sp, 4                        # Restore the stack pointer
    sw $t7, next_capsule_bottom_colour      # Store in next_capsule_bottom_colour
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    # Calculate the memory address for the top pixel.
    sll $t1, $t1, 2                         # Scale X by 4
    sll $t2, $t2, 7                         # Scale Y by 128
    add $t5, $t0, $t1                       # Base + X offset
    add $t5, $t5, $t2                       # Base + Y offset
    lw $t3, next_capsule_top_colour
    sw $t3, 0($t5)                          # Draw top pixel
    
    lw $t3, next_capsule_bottom_colour
    sw $t3, 128($t5)                        # Draw top pixel

update_next_capsule:
    # Load the display address.
    lw $t0, ADDR_DSPL

    # Load the next capsule's position.
    lw $t1, next_capsule_x                  # X position
    lw $t2, next_capsule_y                  # Y position

    # Calculate the memory address for the top pixel.
    sll $t1, $t1, 2                         # Scale X by 4
    sll $t2, $t2, 7                         # Scale Y by 128
    add $t5, $t0, $t1                       # Base + X offset
    add $t5, $t5, $t2                       # Base + Y offset
    lw $t3, next_capsule_top_colour
    sw $t3, 0($t5)                          # Draw top pixel
    
    lw $t3, next_capsule_bottom_colour
    sw $t3, 128($t5)                        # Draw bottom pixel

    jr $ra
    
    
draw_next_capsule1:
    lw $t0, ADDR_DSPL

    lw $t1, next_capsule_x1                
    lw $t2, next_capsule_y1                 

    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal random_colour                      
    lw $t7, 0($sp)                        
    addi $sp, $sp, 4                       
    sw $t7, next_capsule_top_colour1        

    jal random_colour                    
    lw $t7, 0($sp)                         
    addi $sp, $sp, 4                       
    sw $t7, next_capsule_bottom_colour1    
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    sll $t1, $t1, 2                       
    sll $t2, $t2, 7                        
    add $t5, $t0, $t1                    
    add $t5, $t5, $t2                      
    lw $t3, next_capsule_top_colour1
    sw $t3, 0($t5)                        
    
    lw $t3, next_capsule_bottom_colour1
    sw $t3, 128($t5)                        


update_next_capsule_1:
    lw $t0, ADDR_DSPL

    lw $t1, next_capsule_x1             
    lw $t2, next_capsule_y1               

    sll $t1, $t1, 2                      
    sll $t2, $t2, 7                      
    add $t5, $t0, $t1                    
    add $t5, $t5, $t2                    
    lw $t3, next_capsule_top_colour1
    sw $t3, 0($t5)                       
    
    lw $t3, next_capsule_bottom_colour1
    sw $t3, 128($t5)                        

    jr $ra
    
    
draw_next_capsule2:
    lw $t0, ADDR_DSPL

    lw $t1, next_capsule_x2              
    lw $t2, next_capsule_y2               

    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal random_colour                     
    lw $t7, 0($sp)                       
    addi $sp, $sp, 4                        
    sw $t7, next_capsule_top_colour2       

    jal random_colour                      
    lw $t7, 0($sp)                         
    addi $sp, $sp, 4                       
    sw $t7, next_capsule_bottom_colour2      
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    sll $t1, $t1, 2                      
    sll $t2, $t2, 7                     
    add $t5, $t0, $t1                    
    add $t5, $t5, $t2                    
    lw $t3, next_capsule_top_colour2
    sw $t3, 0($t5)                       
    
    lw $t3, next_capsule_bottom_colour2
    sw $t3, 128($t5)                        


update_next_capsule_2:
    lw $t0, ADDR_DSPL

    lw $t1, next_capsule_x2              
    lw $t2, next_capsule_y2               

    sll $t1, $t1, 2                      
    sll $t2, $t2, 7                       
    add $t5, $t0, $t1                    
    add $t5, $t5, $t2                     
    lw $t3, next_capsule_top_colour2
    sw $t3, 0($t5)                       
    
    lw $t3, next_capsule_bottom_colour2
    sw $t3, 128($t5)                      

    jr $ra
    
draw_next_capsule3:
    lw $t0, ADDR_DSPL

    lw $t1, next_capsule_x3              
    lw $t2, next_capsule_y3                

    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal random_colour                    
    lw $t7, 0($sp)                         
    addi $sp, $sp, 4                       
    sw $t7, next_capsule_top_colour3        

    jal random_colour                      
    lw $t7, 0($sp)                          
    addi $sp, $sp, 4                        
    sw $t7, next_capsule_bottom_colour3     
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    sll $t1, $t1, 2                     
    sll $t2, $t2, 7                      
    add $t5, $t0, $t1                    
    add $t5, $t5, $t2                    
    lw $t3, next_capsule_top_colour3
    sw $t3, 0($t5)                        
    
    lw $t3, next_capsule_bottom_colour3
    sw $t3, 128($t5)                       

    jr $ra


# This draws a random virus.
# $a0, $a1, and $v0 are used in the syscall.
# $t0 stores the bitmap location.
# $t1 stores the starting location of possible viruses.
# $t2 stores the random color.
random_virus:
    lw $t0, ADDR_DSPL                       # Store the top left of the bitmap in $t0    
    addi $t1, $t0, 2068                     # Location of the first pixel of the bottom half (13 rows down)
    
    # We find the coordinates of the virus.
    li $v0 , 42                             # Random generator with max
    li $a0 , 0                              # Where the random number is stored
    li $a1 , 7                              # The max random number for X offset
    syscall
    addi $a0, $a0, 8                        # Shift the range to 10–22
    sll $a0, $a0, 2                         # Calculate the X offset
    add $t1, $t1, $a0                       # Add X offset to $t1
    
    li $v0 , 42                             # Random generator with max
    li $a0 , 0                              # Where the random number is stored
    li $a1 , 12                             # The max random number for Y offset
    syscall
    sll $a0, $a0, 7                         # Calculate the Y offset
    add $t1, $t1, $a0                       # Add Y offset to $t1
    
    # Color the virus.
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Store $ra
    
    jal random_colour
    lw $t2, 0($sp)                          # Pop off the random color
    addi $sp, $sp, 4                        # Move the stack pointer
    li $t3, 0xff0000                        # Store Red
    beq $t2, $t3, change_red
    li $t3, 0x00ff00                        # Store Green
    beq $t2, $t3, change_green
    change_blue:
        li $t2, 0x6666ff
        j done_change
    change_green:
        li $t2, 0x66ff66
        j done_change
    change_red:
        li $t2, 0xff6666
        j done_change
    done_change:
    lw $ra, 0($sp)                          # Restore $ra
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t2, 0 ($t1)

    jr $ra


apply_gravity:
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Save return address

    addi $sp, $sp, -4                       # Move the stack pointer
    li $t0, 's'                             # 's' for downward movement
    sw $t0, 0($sp)                          # Store 's' on the stack
    jal check_adjacent_pixel                # Check if the space below is empty

    beqz $v0, gravity_exit                  # Exit if the space below is not empty
    jal move_down                           # Move the capsule down if the space is empty

    lw $t0, gravity_delay                   # Load the current gravity delay
    li $v0, 32                              # Sleep system call
    move $a0, $t0                           # Delay in milliseconds
    syscall                                 # Apply delay

    # Decrease the gravity delay.
    lw $t1, gravity_decrement               # Load decrement value
    sub $t0, $t0, $t1                       # Subtract decrement
    lw $t2, min_gravity_delay               # Load minimum delay
    bge $t0, $t2, skip_update               # If delay is below minimum, skip update
    move $t0, $t2                           # Set delay to minimum
skip_update:
    sw $t0, gravity_delay                   # Store the updated gravity delay

gravity_exit:
    lw $ra, 0($sp)                          # Restore return address
    addi $sp, $sp, 4                        # Restore stack pointer
    
    jr $ra                                  # Return
                              

# THE GAME LOOP.
game_loop:
    # Check if all the viruses have been removed.
    lw $t0, virus_count
    beqz $t0, quit_game
    
    # Check if the game is paused.
    lw $t0, game_paused
    bnez $t0, pause_loop                

    # Play the next note in the background music.
    jal play_current_music_note     

    # If no key is pressed, the capsule remains stationary.
    # Check if the game has started, then apply gravity.
    lw $t1, game_started
    beqz $t1, wait_for_start          
    jal apply_gravity
    
    # Check for keyboard input.
    # This function handles all movement (left, right, down) and rotation of the capsule.
    jal check_keyboard_input
    
    li $v0, 32                              # System call for sleep
    li $a0, 16                              # 16 milliseconds
    syscall                                 # Invoke the system call

    # Repeat the loop to continue the game cycle.
    j game_loop


# Background music functions below.
play_current_music_note:
    lw $t5, current_note_index             

play_next_note:
    la $t2, music_score       
    sll $t3, $t5, 4             
    add $t4, $t2, $t3          

    lw $a0, 0($t4)               
    lw $a1, 4($t4)              
    lw $a2, 8($t4)              
    lw $a3, 12($t4)              
    beqz $a0, reset_score       

    # Syscall to play note.
    li $v0, 33
    syscall

    # Increment the current note index.
    addi $t5, $t5, 1
    sw $t5, current_note_index
    jr $ra

# Reset the music index to start over.
reset_score:
    li $t5, 0
    sw $t5, current_note_index
    jr $ra

pause_loop:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal draw_paused_message                 # Draw the "PAUSED" message
    
pause_wait:
    li $v0, 32                              # System call for sleep
    li $a0, 16                              # 16 milliseconds delay
    syscall                                 # Pause for a short duration

    lw $t0, ADDR_KBRD                       # Load the keyboard address
    lw $t1, 0($t0)                          # Check if a key has been pressed
    beqz $t1, pause_wait                    # If no key is pressed, stay in pause loop

    lw $t2, 4($t0)                          # Load the key value
    li $t3, 'p'                             # Check for 'p'
    beq $t2, $t3, handle_resume             # If 'p' is pressed, handle resume

    j pause_wait                            # Otherwise, keep waiting for valid input


# Pause and Resume functions below.
handle_resume:
    li $t0, 0                               # Clear the pause flag
    sw $t0, game_paused                     # Update the pause flag

    # Short delay to ensure screen refresh
    li $v0, 32                              # System call for sleep
    li $a0, 16                              # Delay (16 ms)
    syscall
    
    clear_paused:
    lw $t0, ADDR_DSPL                       # Load the base address of the display
    li $t1, 0x000000                        # Black color
    li $t2, 0                               # Start index

    clear_paused_loop:
    sw $t1, 0($t0)                          # Set pixel to black
    addi $t0, $t0, 4                        # Move to the next pixel
    addi $t2, $t2, 1                        # Increment pixel counter
    li $t3, 224                             # Total number of pixels 
    bne $t2, $t3, clear_paused_loop         # Continue until all pixels are cleared
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    j game_loop                             # Resume the game loop

toggle_pause:
    lw $t0, game_paused                     # Load the current pause state
    xori $t0, $t0, 1                        # Toggle the state (0 -> 1 or 1 -> 0)
    sw $t0, game_paused                     # Store the new state
    jr $ra                                  

pause_loop_end:
    jr $ra                              

# Check if a key has been pressed to start the game
wait_for_start:
    lw $t0, ADDR_KBRD                       # Load keyboard address
    lw $t1, 0($t0)                          # Check if a key has been pressed
    beq $t1, $zero, wait_for_start          # If no key is pressed, keep waiting

    li $t2, 1                               # Set game_started to 1
    sw $t2, game_started
    j game_loop                             # Restart the game loop
    
    
# This checks if a key has been pressed on the keyboard.
# $t0 is the keyboard address.
# $t1 stores if a key has been pressed.
# $t2 stores the value of the key that was pressed.
# $t3 stores either 'a', 's', 'd', 'w', 'q', 'p'.
check_keyboard_input:
    lw $t0, ADDR_KBRD                       # Load keyboard address
    lw $t1, 0($t0)                          # Check if a key has been pressed
    beq $t1, $zero, no_input                # When no key pressed

    lw $t2, 4($t0)           
    li $t3, 'a'                             # 'a' (move left)
    beq $t2, $t3, move_left
    li $t3, 'd'                             # 'd' (move right)
    beq $t2, $t3, move_right
    li $t3, 's'                             # 's' (move down)
    beq $t2, $t3, move_down
    li $t3, 'w'                             # 'w' (rotate)
    beq $t2, $t3, rotate_capsule
    li $t3, 'q'                             # 'q' (quit)
    beq $t2, $t3, quit_game
    li $t3, 'p'                         # 'p' (pause/resume)
    beq $t2, $t3, toggle_pause          # Call toggle_pause when 'p' is pressed

no_input:
    jr $ra
    
quit_game:
    li $v0, 10                              # System call for exit
    syscall                                 # Terminate the program


# This part is executed when the keyboard reads 'a'.
# $t0 is the capsule's x position.
# $t2 is the top capsule's color.
# $t3 is the bottom capsule's color.
# $t4 stores the colors that the capsules will be set to.
move_left:
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Store $ra
    
    addi $sp, $sp, -4                       # Move the stack pointer
    addi $t0, $zero, 'a'
    sw $t0, 0($sp)                          # Store 'a'
    jal check_adjacent_pixel                # Check if the pixel to the left is black
    beqz $v0, move_left_exit                # If the pixel is not black, exit the function
    
    lw $t2, capsule_top_colour
    lw $t3, capsule_bottom_colour
    li $t4, 0x000000                        # Black
    
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $t2, 0($sp)                          # Store $t2 top color
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $t3, 0($sp)                          # Store $t3 bottom color
    
    sw $t4, capsule_top_colour              # Change color to black
    sw $t4, capsule_bottom_colour           # Change color to black
    jal draw_capsule                        # Draw over the current capsule
    
    lw $t0, current_capsule_x
    addi $t0, $t0, -1                       # Move to the left
    sw $t0, current_capsule_x               # Store the new location in current_capsule_x
    
    lw $t4, 0($sp)                          # Pop off the bottom color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_bottom_colour
    
    lw $t4, 0($sp)                          # Pop off the top color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_top_colour
    jal draw_capsule                        # Draw the new capsule
    
    move_left_exit:
    jal check_collision                     # Check if there was a collision
    lw $ra, 0($sp)                          # Pop off $ra
    addi $sp, $sp, 4                        # Move the stack pointer
    
    jr $ra


# This part is executed when the keyboard reads 'd'.
# $t0 is the capsule's x position.
# $t2 is the top capsule's color.
# $t3 is the bottom capsule's color.
# $t4 stores the colors that the capsules will be set to.
move_right:
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Store $ra
    
    addi $sp, $sp, -4                       # Move the stack pointer
    addi $t0, $zero, 'd'
    sw $t0, 0($sp)                          # Store 'd'
    jal check_adjacent_pixel                # Check if the pixel to the left is black
    beqz $v0, move_right_exit               # If the pixel is not black, exit the function
    
    lw $t2, capsule_top_colour
    lw $t3, capsule_bottom_colour
    li $t4, 0x000000                        # Black
    
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $t2, 0($sp)                          # Store $t2 top color
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $t3, 0($sp)                          # Store $t3 bottom color
    
    sw $t4, capsule_top_colour              # Change color to black
    sw $t4, capsule_bottom_colour           # Change color to black
    jal draw_capsule                        # Draw over the current capsule
    
    lw $t0, current_capsule_x
    addi $t0, $t0, 1                        # Move to the right
    sw $t0, current_capsule_x               # Store the new location in current_capsule_x
    
    lw $t4, 0($sp)                          # Pop off the bottom color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_bottom_colour
    
    lw $t4, 0($sp)                          # Pop off the top color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_top_colour
    jal draw_capsule                        # Draw the new capsule
    
    move_right_exit:
    jal check_collision                     # Check if there was a collision
    lw $ra, 0($sp)                          # Pop off $ra
    addi $sp, $sp, 4                        # Move the stack pointer
    
    jr $ra


# This part is executed when the keyboard reads 's'.
# $t0 is the capsule's y position.
# $t2 is the top capsule's color.
# $t3 is the bottom capsule's color.
# $t4 stores the colors that the capsules will be set to.
move_down:
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Store $ra
    
    addi $sp, $sp, -4                       # Move the stack pointer
    addi $t0, $zero, 's'
    sw $t0, 0($sp)                          # Store 's'
    jal check_adjacent_pixel                # Check if the pixel to the left is black
    beqz $v0, move_down_exit                # If the pixel is not black, exit the function
    
    lw $t2, capsule_top_colour
    lw $t3, capsule_bottom_colour
    li $t4, 0x000000                        # Black
    
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $t2, 0($sp)                          # Store $t2 top color
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $t3, 0($sp)                          # Store $t3 bottom color
    
    sw $t4, capsule_top_colour              # Change color to black
    sw $t4, capsule_bottom_colour           # Change color to black
    jal draw_capsule                        # Draw over the current capsule
    
    lw $t0, current_capsule_y
    addi $t0, $t0, 1                        # Move down
    sw $t0, current_capsule_y               # Store the new location in current_capsule_yx
    
    lw $t4, 0($sp)                          # Pop off the bottom color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_bottom_colour
    
    lw $t4, 0($sp)                          # Pop off the top color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_top_colour
    jal draw_capsule                        # Draw the new capsule
    
    # Play drop sound.
    li $a0, 60                             
    li $a1, 50                     
    li $a2, 15                   
    li $a3, 10                   
    jal play_sound                

    move_down_exit:
    jal check_collision                     # Check if there was a collision
    lw $ra, 0($sp)                          # Pop off $ra
    addi $sp, $sp, 4                        # Move the stack pointer
    
    jr $ra


# This part is executed when the keyboard reads 'w'.
# $t0 deals with the capsule's orientation.
# $t1 stores the capsule's y position.
# $t2 is the top capsule's color.
# $t3 is the bottom capsule's color.
# $t4 stores the colors that the capsules will be set to.
rotate_capsule:
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Store $ra
    
    addi $sp, $sp, -4                       # Move the stack pointer
    addi $t0, $zero, 'w'
    sw $t0, 0($sp)                          # Store 'w'
    jal check_adjacent_pixel                # Check if the pixel to the left is black
    beqz $v0, rotate_exit                   # If the pixel is not black, exit the function
    
    lw $t2, capsule_top_colour
    lw $t3, capsule_bottom_colour
    li $t4, 0x000000                        # Black
    
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $t2, 0($sp)                          # Store $t2 top color
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $t3, 0($sp)                          # Store $t3 bottom color
    
    sw $t4, capsule_top_colour              # Change color to black
    sw $t4, capsule_bottom_colour           # Change color to black
    jal draw_capsule                        # Draw over the current capsule
    
    lw $t0, capsule_orientation
    beq $t0, $zero, horizontal_to_vertical  # If orientation is 0, we need to make it veritcal
    
    # Play rotate sound.
    li $a0, 64                     
    li $a1, 100                    
    li $a2, 10                    
    li $a3, 30                    
    jal play_sound                  

    vertical_to_horizontal:                 # Switch from vertical to horizontal
    lw $t1, current_capsule_y               # We need to make the representative capsule the bottom capsule location
    addi $t1, $t1, 1
    sw $t1, current_capsule_y
    sw $zero, capsule_orientation           # Change the orientation
    
    lw $t4, 0($sp)                          # Pop off the bottom color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_bottom_colour
    
    lw $t4, 0($sp)                          # Pop off the top color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_top_colour
    
    j end_rotate
    
    horizontal_to_vertical:                 # Switch from horizontal to vertical
    lw $t1, current_capsule_y               # We need to make the representative capsule one up from the current capsule location (restores the original vertical position)
    addi $t1, $t1, -1
    sw $t1, current_capsule_y
    addi $t0, $zero, 1                      # Store 1
    sw $t0, capsule_orientation             # Change the orientation
    
    # Need to switch the top and bottom colors.
    lw $t4, 0($sp)                          # Pop off the bottom color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_top_colour
    
    lw $t4, 0($sp)                          # Pop off the top color
    addi $sp, $sp, 4                        # Move the stack pointer
    sw $t4, capsule_bottom_colour
    end_rotate:
    
    jal draw_capsule                        # Draw the new capsule
    
    rotate_exit:
    jal check_collision                     # Check if there was a collision
    lw $ra, 0($sp)                          # Pop off $ra
    addi $sp, $sp, 4                        # Move the stack pointer
    
    jr $ra


# This function checks if a specific pixel adjacent to the capsule is black (empty).
# The direction to check (left, right, down, or rotate) is passed via the stack.
# It determines whether a move or rotation is possible without collisions.
# Returns 1 in $v0 if the pixel is black, and 0 if it's not.
check_adjacent_pixel:
    li $s0, 0x000000                        # Load the value for black (empty pixel)
    lw $t0, ADDR_DSPL                       # Load the base address of the bitmap display
    
    # Load the current X and Y coordinates of the capsule.
    lw $t1, current_capsule_x               # Load the capsule's X coordinate.
    lw $t2, current_capsule_y               # Load the capsule's Y coordinate.
    
    # Calculate the position of the capsule in memory.
    sll $t1, $t1, 2                         # Scale the X coordinate to match the bitmap pixel layout.
    sll $t2, $t2, 7                         # Scale the Y coordinate to match the bitmap pixel layout.
    add $t3, $t1, $t0                       # Base address + X offset
    add $t3, $t3, $t2                       # Base address + Y offset
    
    lw $t4, capsule_orientation
    
    # Determine which direction to check based on the input direction.
    lw $s1, 0($sp) # Pop off the direction
    addi $sp, $sp, 4                        # Move the stack pointer
    li $s2, 'a'                             # Left
    beq $s1, $s2, left
    li $s2, 'd'                             # Right
    beq $s1, $s2, right
    li $s2, 's'                             # Down
    beq $s1, $s2, down
    li $s2, 'w'                             # Rotate
    beq $s1, $s2, rotate
    
    # Check if the left pixel is black (empty).
    left:
    addi $t3, $t3, -4                       # This is the pixel to the left of the top part of the capsule
    
    lw $t5, 0 ($t3)                         # The color of the pixel to the left of the top part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is not black, branch to `is_not_black`
    
    beqz $t4, done_check                    # If horizontal only need to check the square next to (X, Y)
    
    # This is for if the pixel is vertical
    addi $t3, $t3, 128                      # This is the position of the pixel to the left of the bottom part of the capsule
    lw $t5, 0 ($t3)                         # The color of the pixel to the left of the bottom part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_not_black`
    j done_check
    
    # Check if the right pixel is black (empty).
    right:
    addi $t3, $t3, 4                        # This is the pixel to the right of the top part of the capsule

    beqz $t4, check_horizontal              # If horizontal only need to check the square next to (X + 1, Y)
    
    # This is for if the pixel is vertical
    lw $t5, 0 ($t3)                         # The color of the pixel to the right of the bottom part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_not_black`
    addi $t3, $t3, 128                      # This is the position of the pixel to the right of the bottom part of the capsule
    lw $t5, 0 ($t3)                         # The color of the pixel to the left of the bottom part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_not_black`
    j done_check
    
    check_horizontal:
    addi $t3, $t3, 4                        # This is the pixel to the right of the right part of the capsule (horizontal)
    lw $t5, 0 ($t3)                         # The color of the pixel to the left of the bottom part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_black`
    j done_check
    
    # Check if the bottom pixel is black (empty).
    down:
    addi $t3, $t3, 128                      # This is the pixel below the top part of the capsule

    beqz $t4, check_h_d                     # If horizontal 
    
    # This is for if the pixel is vertical
    addi $t3, $t3, 128                      # This is the pixel below the bottom part of the capsule
    lw $t5, 0 ($t3)                         # The color of the pixel to the left of the bottom part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_black`
    j done_check
    
    check_h_d:
    lw $t5, 0 ($t3)                         # The color of the pixel below the left part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_not_black`
    addi $t3, $t3, 4                        # This is the position of the pixel below the right part of the capsule
    lw $t5, 0 ($t3)                         # The color of the pixel to the left of the bottom part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_not_black`
    j done_check  
    
    # Check for collisions during rotation.
    rotate:
    beqz $t4, check_h_rotate                # If horizontal, perform checks for rotation. 
    
    # If vertical, treat as a right movement.
    j right
    check_h_rotate:
    addi $t3, $t3, -128                     # This is the pixel above the left part of the capsule
    lw $t5, 0 ($t3)                         # The color of the pixel below the left part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_not_black`
    addi $t3, $t3, 4                        # This is the position of the pixel above the right part of the capsule
    lw $t5, 0 ($t3)                         # The color of the pixel above the right part of the capsule
    bne $t5, $s0, is_not_black              # If the pixel is black, branch to `is_not_black`
    j done_check
    
    # End of checks.
    done_check:
        li $v0, 1                           # If the pixel is black, return 1
        jr $ra                              # Return to the calling function
    is_not_black:
        li $v0, 0                           # If the pixel is not black, return 0
        jr $ra                              # Return to the calling function


check_collision:
    li $s0, 0x000000                        # Load the value for black (empty pixel)
    li $s1, 0x808080                        # Load the value for grey (bottom of bottle)
    lw $t0, ADDR_DSPL                       # Load the base address of the bitmap display
    
    lw $t1, current_capsule_x
    lw $t2, current_capsule_y
    
    # we calculate capsule position
    sll $t1, $t1, 2                         # Scale X
    sll $t2, $t2, 7                         # Scale Y
    add $t3, $t1, $t0                       # Base address + X offset
    add $t3, $t3, $t2                       # Base address + Y offset
    
    lw $t4, capsule_orientation
    
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Store $ra
    
    beqz $t4, horizontal_collision 
    vertical_collision:
        addi $t3, $t3, 256                  # We need to check the location under the lower part of the capsule
        lw $t5, 0($t3)                      # The color of the location under the lower part of the capsule
        beq $t5, $s0, done_collision_check  # If equal to black, we're done
        
        # If it is not black, we have run into the boundry or a virus. We need to check for matches. 
        # Store the capsule in the array.
            la $t6, capsules                # Base address of capsules array
            lw $t7, next_free_index         # Load the index of the next free capsule entry
            add $t8, $t6, $t7               # $t8 = address of the current capsule entry
        
            # Store capsule data.
            lw $t1, current_capsule_x
            lw $t2, current_capsule_y
            sw $t1, 0($t8)                  # Store x-coordinate (passed in $a0)
            sw $t2, 4($t8)                  # Store y-coordinate (passed in $a1)
            li $t9, 1                       # Full flag (1 = capsule is full)
            sw $t9, 8($t8)                  # Store full flag
            sw $t4, 12($t8)                 # Store orientation
        
            # Update next_free_index.
            lw $t9, next_free_index         # Load the current index
            addi $t9, $t9, 16               # Increment index by 1
            sw $t9, next_free_index         # Store the updated index
        jal virus_collision       
        
        j done_collision_check    
    horizontal_collision:
        addi $t3, $t3, 128                  # We need to check the location under the left side of the capsule
        lw $t5, 0($t3)                      # The color of the location under the lower part of the capsule
        beq $t5, $s0, right_side            # If it is not black, we have run into the boundry or a virus. We need to check for matches.
            # Store the capsule in the array.
            la $t6, capsules                # Base address of capsules array
            lw $t7, next_free_index         # Load the index of the next free capsule entry
            add $t8, $t6, $t7               # $t8 = address of the current capsule entry
        
            # Store capsule data.
            lw $t1, current_capsule_x
            lw $t2, current_capsule_y
            sw $t1, 0($t8)                  # Store x-coordinate (passed in $a0)
            sw $t2, 4($t8)                  # Store y-coordinate (passed in $a1)
            li $t9, 1                       # Full flag (1 = capsule is full)
            sw $t9, 8($t8)                  # Store full flag
            sw $t4, 12($t8)                 # Store orientation
        
            # Update next_free_index.
            lw $t9, next_free_index         # Load the current index
            addi $t9, $t9, 16               # Increment index by 1
            sw $t9, next_free_index         # Store the updated index
            jal virus_collision
            j done_collision_check
            
        right_side:
        addi $t3, $t3, 4                    # We need to check the location under the right side of the capsule
        lw $t5, 0($t3)                      # The color of the location under the lower part of the capsule
        beq $t5, $s0, done_collision_check  # If it is not black, we have run into the boundry or a virus. We need to check for matches.
            # Store the capsule in the array.
            la $t6, capsules                # Base address of capsules array
            lw $t7, next_free_index         # Load the index of the next free capsule entry
            add $t8, $t6, $t7               # $t8 = address of the current capsule entry
        
            # Store capsule data.
            lw $t1, current_capsule_x
            lw $t2, current_capsule_y
            sw $t1, 0($t8)                  # Store x-coordinate (passed in $a0)
            sw $t2, 4($t8)                  # Store y-coordinate (passed in $a1)
            li $t9, 1                       # Full flag (1 = capsule is full)
            sw $t9, 8($t8)                  # Store full flag
            sw $t4, 12($t8)                 # Store orientation
        
            # Update next_free_index.
            lw $t9, next_free_index         # Load the current index
            addi $t9, $t9, 16               # Increment index by 1
            sw $t9, next_free_index         # Store the updated index
            jal virus_collision
    done_collision_check:
    lw $ra, 0($sp)                          # Pop off $ra
    addi $sp, $sp, 4                        # Move the stack pointer
    jr $ra

# Functions to check game over state.
check_bottle_entrance:
    lw $t0, ADDR_DSPL                       # Load the base address of the display
    addi $t1 ,$t0, 1216                     # location for entrance (right under the capsule X=16, Y=9)
    li $t2, 0x000000                        # Black color (empty pixel)

    lw $t3, 0($t1)                          # Load the color of the current pixel
    bne $t3, $t2, entrance_full             # If the pixel is not black, increment count
    jr $ra                                  # Return

entrance_full:
    jal draw_game_over_message
    
    # Until player presses Q to quit, see if they want to restart R.
    lw $t0, ADDR_KBRD                       # Load keyboard address
    
    # Play game over sound.
    li $a0, 80                      
    li $a1, 100                     
    li $a2, 15                     
    li $a3, 100                     
    jal play_sound                
    li $a0, 70                    
    li $a1, 100                    
    li $a2, 15                    
    li $a3, 100                    
    jal play_sound               
    li $a0, 60                     
    li $a1, 100                  
    li $a2, 15                     
    li $a3, 100                     
    jal play_sound                
    li $a0, 50                     
    li $a1, 100                     
    li $a2, 15                   
    li $a3, 100                    
    jal play_sound                 
    li $a0, 40                     
    li $a1, 200                     
    li $a2, 15                      
    li $a3, 100                     
    jal play_sound                

    loop:
    lw $t1, 0($t0)                          # Check if a key has been pressed
    beq $t1, $zero, loop                    # No key pressed, keep polling
    
    lw $t2, 4($t0)                          # Load the key value
    li $t3, 'q'                             # Check if key is 'q'
    beq $t2, $t3, quit_game

    li $t3, 'r'                             # Check if key is 'r'
    beq $t2, $t3, main
    j loop                                  # Continue polling


virus_collision:
    li $s0, 0x000000                        # Load the value for black (empty pixel) in $s0
    li $s1, 0x808080                        # Load the value for grey (bottom of bottle) in $s1
    li $s2, 1                               # Load a 1 in $s2
    li $s3, 0                               # Initialize a flag to see if a change was made in $s3
    
    # We need to traverse through the whole map start a whole loop.
    # We will start at the top left of the bottle.
    lw $t0, ADDR_DSPL                       # Load the base address of the bitmap display, stored in $t0
    # the top left corner of the bottle.
    addi $t1, $zero, 11                     # Set the X coordinate 5
    addi $t2, $zero, 10                     # Set the Y coordinate 4
    # we calculate capsule position.
    sll $t1, $t1, 2                         # scale X
    sll $t2, $t2, 7                         # scale Y
    add $t3, $t1, $t0                       # Base address + X offset
    add $t4, $t3, $t2                       # Base address + Y offset, stored in $t4
    # the bottom right corner of the bottle.
    addi $t1, $zero, 19                     # Set the X coordinate 
    addi $t2, $zero, 27                     # Set the Y coordinate 
    # we calculate capsule position.
    sll $t1, $t1, 2                         # Scale X
    sll $t2, $t2, 7                         # Scale Y
    add $t3, $t1, $t0                       # Base address + X offset
    add $t5, $t3, $t2                       # Base address + Y offset, stored in $t5
    
    
    addi $sp, $sp, -4                       # Move the stack pointer
    sw $ra, 0($sp)                          # Store $ra
    
    addi $t3, $zero, 10                     # Counter to store how many X values over we have gone. Starts at 10 (for width 11).
    
    # Play collision sound.
    li $a0, 72                   
    li $a1, 150                 
    li $a2, 5                    
    li $a3, 50                 
    jal play_sound                
    
    # Need to traverse all ways to ensure that we always can get the virus. 
    # For instance, since we check if the color is red, blue, or green, it does not account for when the current pixel is a virus.
    traverse:
        lw $t1, 0($t4)                      # $t1 stores the color of the current pixel
        beq $t1, $s0, next_iteration        # If the square is black, then we do not need to check
        beq $t1, $s1, next_iteration        # If the square is grey, then we do not need to check
        
        li $t2, 0xff0000                       
        beq $t2, $t1, red
        li $t2, 0x00ff00                        
        beq $t2, $t1, green
        blue:
            li $t2, 0x6666ff                # $t2 will hold the virus blue color
            j done_accepted_colors
        green:
            li $t2, 0x66ff66                # $t2 will hold the virus green color
            j done_accepted_colors
        red:
            li $t2, 0xff6666                # $t2 will hold the virus red color
            j done_accepted_colors
        done_accepted_colors:
        
        # Need to check L/R groups of four.
        check_left:
        addi $t6, $t4, 4
        addi $t7, $t4, 8
        addi $t8, $t4, 12
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t6, 0($sp)                      # Store $t6
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t7, 0($sp)                      # Store $t7
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t8, 0($sp)                      # Store $t8
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t2, 0($sp)                      # Store $t2
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t1, 0($sp)                      # Store $t1
        jal check_adjacent
        bne $v0, $s2, check_right
        
        # Handle where we need to erase and drop.
        # Colour the 4 matching black.
        sw $s0, 0($t4)
        sw $s0, 0($t6)
        sw $s0, 0($t7)
        sw $s0, 0($t8)
        
        sub $a0, $t4, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t6, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t7, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t8, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        jal check_drops
        
        addi $s3, $s3, 1                    # Record that a change has been made
        j done_traversal
        
        check_right:
        addi $t6, $t4, -4
        addi $t7, $t4, -8
        addi $t8, $t4, -12
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t6, 0($sp)                      # Store $t6
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t7, 0($sp)                      # Store $t7
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t8, 0($sp)                      # Store $t8
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t2, 0($sp)                      # Store $t2
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t1, 0($sp)                      # Store $t1
        jal check_adjacent
        bne $v0, $s2, check_down
        
        # Handle where we need to erase and drop
        # Color the 4 matching black
        sw $s0, 0($t4)
        sw $s0, 0($t6)
        sw $s0, 0($t7)
        sw $s0, 0($t8)
        
        sub $a0, $t4, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t6, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t7, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t8, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        jal check_drops
        
        addi $s3, $s3, 1                    # Record that a change has been made
        j done_traversal
        
        check_down:
        # Need to check U/D groups of four
        addi $t6, $t4, 128
        addi $t7, $t4, 256
        addi $t8, $t4, 384
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t6, 0($sp)                      # Store $t6
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t7, 0($sp)                      # Store $t7
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t8, 0($sp)                      # Store $t8
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t2, 0($sp)                      # Store $t2
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t1, 0($sp)                      # Store $t1
        jal check_adjacent
        bne $v0, $s2, check_up
        
        # Need to handle where we erase and drop
        # Color the 4 matching black
        sw $s0, 0($t4)
        sw $s0, 0($t6)
        sw $s0, 0($t7)
        sw $s0, 0($t8)
        sub $a0, $t4, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t6, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t7, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t8, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        jal check_drops
        
        addi $s3, $s3, 1                    # Record that a change has been made
        j done_traversal
        
        check_up:
        # Need to check U/D groups of four.
        addi $t6, $t4, -128
        addi $t7, $t4, -256
        addi $t8, $t4, -384
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t6, 0($sp)                      # Store $t6
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t7, 0($sp)                      # Store $t7
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t8, 0($sp)                      # Store $t8
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t2, 0($sp)                      # Store $t2
        addi $sp, $sp, -4                   # Move the stack pointer
        sw $t1, 0($sp)                      # Store $t1
        jal check_adjacent
        bne $v0, $s2, next_iteration
        
        # Need to handle where we erase and drop
        # Colour the 4 matching black
        sw $s0, 0($t4)
        sw $s0, 0($t6)
        sw $s0, 0($t7)
        sw $s0, 0($t8)
        sub $a0, $t4, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t6, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t7, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        sub $a0, $t8, $t0                   # $a0 stores the offset without the bitmap addr
        jal update_array
        
        jal check_drops
        
        addi $s3, $s3, 1                    # Record that a change has been made
        j done_traversal
        
        next_iteration:
        beq $t4, $t5, done_traversal
            beq $t3, $zero, add_84
            addi $t4, $t4, 4                # If it not on the far right side, we just need to move to the next pixel
            addi $t3, $t3, -1               # Update $t3
            j traverse
            add_84:
            addi $t4, $t4, 88               # If it is the far right side, we just need to move the next row of the bottle
            addi $t3, $zero, 10             # restore $s4
            j traverse
    done_traversal:
        beq $s3, $zero, done_virus_collision
        lw $ra, 0($sp)                      # Pop off $ra
        addi $sp, $sp, 4                    # Move the stack pointer
        j virus_collision
        
    done_virus_collision:
        jal check_bottle_entrance
        
        # Put the next capsule color into the current capsule colour.
        lw $t0, next_capsule_top_colour
        sw $t0, capsule_top_colour
        lw $t0, next_capsule_bottom_colour
        sw $t0, capsule_bottom_colour
        lw $t0, next_capsule_top_colour1
        sw $t0, next_capsule_top_colour
        lw $t0, next_capsule_bottom_colour1
        sw $t0, next_capsule_bottom_colour
        lw $t0, next_capsule_top_colour2
        sw $t0, next_capsule_top_colour1
        lw $t0, next_capsule_bottom_colour2
        sw $t0, next_capsule_bottom_colour1
        lw $t0, next_capsule_top_colour3
        sw $t0, next_capsule_top_colour2
        lw $t0, next_capsule_bottom_colour3
        sw $t0, next_capsule_bottom_colour2
        
        li $t0, 16                              # Default X position for the capsule
        sw $t0, current_capsule_x               # Store in current_capsule_x
        li $t0, 7                               # Default Y position for the capsule
        sw $t0, current_capsule_y               # Store in current_capsule_y
        li $t0, 1                               # Vertical orientation
        sw $t0, capsule_orientation             # Store in capsule_orientation
        
        jal draw_capsule           
        
        # Redraw the capsules.
        jal update_next_capsule  
        jal update_next_capsule_1  
        jal update_next_capsule_2   
        jal draw_next_capsule3      
        
        lw $ra, 0($sp)             
        addi $sp, $sp, 4           
        jr $ra                     

check_adjacent:
        li $s0, 0x000000                        # Load the value for black (empty pixel)
        lw $t1, 0($sp)                          # Pop off $t1
        addi $sp, $sp, 4                        # Move the stack pointer
        lw $t2, 0($sp)                          # Pop off $t2 (virus color)
        addi $sp, $sp, 4                        # Move the stack pointer
        
        lw $t8, 0($sp)                          # Pop off $t8
        addi $sp, $sp, 4                        # Move the stack pointer
        lw $t7, 0($sp)                          # Pop off $t7
        addi $sp, $sp, 4                        # Move the stack pointer
        lw $t6, 0($sp)                          # Pop off $t6
        addi $sp, $sp, 4                        # Move the stack pointer
        
        lw $s5, 0 ($t8)                         # Get the color of $t8
        lw $s6, 0 ($t7)                         # Get the color of $t7
        lw $s7, 0 ($t6)                         # Get the color of $t6
        
        li $t9, 0                               # Number of viruses present in the sequence
        # Check t6 against both colors.
        beq $s7, $t1, check_t7
        beq $s7, $t2, virus_present_1
        j not_all_match        
        
        virus_present_1:
            addi $t9, $t9, 1
            j check_t7
            
        check_t7:
                # Check t7 against both colours.
                beq $s6, $t1, check_t8
                beq $s6, $t2, virus_present_2
                j not_all_match       
        
        virus_present_2:
            addi $t9, $t9, 1
            j check_t8
            
        check_t8:
                # Check t8 against both colours.
                beq $s5, $t1, all_match
                beq $s5, $t2, virus_present_3
                j not_all_match       
        
        virus_present_3:
            addi $t9, $t9, 1
            j all_match
            
        all_match:
                lw $s4, virus_count
                sub $s4, $s4, $t9
                sw $s4, virus_count
                li $v0, 1                       # If there is a match, return 1
                jr $ra
        
        not_all_match:   
                li $v0, 0                       # If there is no match, return 0
                jr $ra

  
vertical_drop:
# Drop the pixel and anything that is on top of it.
    li $s0, 0x000000                            # Load the value for black 
    li $s1, 0x808080                            # Load the value for grey 
    lw $t3, 0($sp)                              # Pop off $t3 (current pixel we are looking at)
    addi $sp, $sp, 4                            # Move the stack pointer
    
    addi $t6, $t3, 128                          # The pixel below the block
    addi $t8, $t3, 0                            # The block itself
    
    # First check if there is a block (aka not grey and not black).
    lw $t3, 0($t3)                              # This is the color of the capsule at the starting position
    beq $t3, $s0, done_drop                     # This is a black block
    beq $t3, $s0, done_drop                     # This is a grey block
    
    go_down:
    lw $t7, 0($t6)                              # This is the color of the capsule at that position
    bne $s0, $t7, start_drop                    # If the color is not black, $t6 now stores the nearest non-black capsule down
    addi $t6, $t6, 128                          # Else, go to the next row down
    j go_down
    
    start_drop:
    addi $t6, $t6, -128                         # This is the first available spot to draw
    beq $t6, $t8, done_drop                     # We are at the bottom/ on a surface already
    
    drop:
    lw $s2, 0($t8)                              # The color of the pixel above we want to copy
    beq $s0, $s2, done_drop                     # We have hit a black, we are done dropping
    beq $s1, $s2, done_drop                     # We have hit the boundry
    sw $s2, 0($t6)                              # draw the same color in the available spot
    
    # Colour the curren pixel we copied black.
    sw $s0, 0($t8)
    # Move both pointers up.
    addi $t6, $t6, -128
    addi $t8, $t8, -128
    j drop
    
    done_drop:
    jr $ra
   
# Note $a0 holds the pixel deleted.
update_array:
    # Save registers on the stack.
    addi $sp, $sp, -32                          # Make room for 8 registers (36 bytes)
    sw   $s0, 0($sp)                            # Save $s0
    sw   $s1, 4($sp)                            # Save $s1
    sw   $s2, 8($sp)                            # Save $s2
    sw   $s3, 12($sp)                           # Save $s3
    sw   $s4, 16($sp)                           # Save $s4
    sw   $s5, 20($sp)                           # Save $s5
    sw   $s6, 24($sp)                           # Save $s6
    sw   $s7, 28($sp)                           # Save $s7
    
    # Set up for the loop.
    la   $s0, capsules                          # Load the base address of the array
    addi $s1, $zero, 0                          # Initialize loop counter (i = 0)
    addi $s2, $zero, 99                         # Length of array (number of elements)

loop_array:
    bge  $s1, $s2, end_loop                     # Exit the loop if i >= length of array
    
    # Load capsule data (x, y, orientation, flag).
    lw   $s3, 0($s0)                            # Load X coordinate
    lw   $s4, 4($s0)                            # Load Y coordinate
    lw   $s5, 12($s0)                           # Load orientation
    
    # Calculate offset based on X and Y coordinates.
    sll  $s3, $s3, 2                            # Multiply X by 4 (word size)
    sll  $s4, $s4, 7                            # Multiply Y by 128 (shift by 7 bits)
    add  $s3, $s3, $s4                          # Calculate offset (X + Y)
    
    # Check if capsule needs to be updated or removed.
    beq  $a0, $s3, update_capsule_original
    addi $s4, $s3, 128                          # Check capsule's bottom position
    beq  $a0, $s4, update_capsule
    
    # Continue to next element in array.
next:
    addi $s0, $s0, 16                           # Move to the next element (16 bytes)
    addi $s1, $s1, 1                            # Increment loop counter
    j loop_array                                # Jump back to the loop
    
update_capsule_original:
    lw   $s6, 8($s0)                            # Load the capsule's flag
    bne  $s6, $zero, full_capsule
    
    # Handle half capsule (set it to 0).
    sw   $zero, 0($s0)                          # Clear X coordinate
    sw   $zero, 4($s0)                          # Clear Y coordinate
    sw   $zero, 8($s0)                          # Clear flag
    sw   $zero, 12($s0)                         # Clear orientation
    j end_loop
    
full_capsule:
    sw   $zero, 8($s0)                          # Update flag to mark as half capsule
    
    # Move capsule by 1 unit (either X or Y).
    beq  $s5, $zero, add_1_x
    lw   $s7, 4($s0)                            # Load Y coordinate
    addi $s7, $s7, 1                            # Increment Y coordinate
    sw   $s7, 4($s0)                            # Store updated Y coordinate
    j end_loop
    
add_1_x:
    lw   $s7, 0($s0)                            # Load X coordinate
    addi $s7, $s7, 1                            # Increment X coordinate
    sw   $s7, 0($s0)                            # Store updated X coordinate
    j end_loop

update_capsule:
    lw   $s6, 8($s0)                            # Load the flag
    bne  $s6, $zero, full_capsule_2
    
    # Half capsule removal logic.
    sw   $zero, 0($s0)                          # Clear X coordinate
    sw   $zero, 4($s0)                          # Clear Y coordinate
    sw   $zero, 8($s0)                          # Clear flag
    sw   $zero, 12($s0)                         # Clear orientation
    j end_loop
    
full_capsule_2:
    sw   $zero, 8($s0)                          # Update flag to mark as half capsule
    j end_loop

end_loop:
    # Restore registers.
    lw   $s0, 0($sp)                            # Restore $s0
    addi $sp, $sp, 4
    lw   $s1, 0($sp)                            # Restore $s1
    addi $sp, $sp, 4
    lw   $s2, 0($sp)                            # Restore $s2
    addi $sp, $sp, 4
    lw   $s3, 0($sp)                            # Restore $s3
    addi $sp, $sp, 4
    lw   $s4, 0($sp)                            # Restore $s4
    addi $sp, $sp, 4
    lw   $s5, 0($sp)                            # Restore $s5
    addi $sp, $sp, 4
    lw   $s6, 0($sp)                            # Restore $s6
    addi $sp, $sp, 4
    lw   $s7, 0($sp)                            # Restore $s7
    addi $sp, $sp, 4
    
    jr   $ra                                    # Return from function
    
   
check_drops:
    # Save registers on the stack.
    addi $sp, $sp, -60                          # Make room for 8 registers (60 bytes total)
    sw   $s0, 0($sp)                            # Save $s0
    sw   $s1, 4($sp)                            # Save $s1
    sw   $s2, 8($sp)                            # Save $s2
    sw   $s3, 12($sp)                           # Save $s3
    sw   $s4, 16($sp)                           # Save $s4
    sw   $s5, 20($sp)                           # Save $s5
    sw   $s6, 24($sp)                           # Save $s6
    sw   $s7, 28($sp)                           # Save $s7
    sw   $t0, 32($sp)                           # Save $t0
    sw   $t1, 36($sp)                           # Save $t1
    sw   $t2, 40($sp)                           # Save $t2
    sw   $t3, 44($sp)                           # Save $t3
    sw   $t4, 48($sp)                           # Save $t4
    sw   $t5, 52($sp)                           # Save $t5
    sw   $t6, 56($sp)                           # Save $t6

    # Set up for the loop.
    la   $s0, capsules                          # Load the base address of the array
    addi $s1, $zero, 0                          # Initialize loop counter (i = 0)
    lw $s2, next_free_index                     # Length of array (number of elements)
    addi $t0, $zero, 0                          # Variable to keep track if we dropped anything

loop_array_:
    bge  $s1, $s2, end_loop_                    # Exit the loop if i >= length of array

    # Load capsule data (x, y, orientation, flag).
    lw   $s3, 0($s0)                            # Load X coordinate
    lw   $s4, 4($s0)                            # Load Y coordinate
    lw   $s5, 12($s0)                           # Load orientation
    lw   $s6, 8($s0)                            # Load flag
    
    # If x and Y is zero, this capsule has been erased (need to skip).
    # Calculate offset based on X and Y coordinates.
    sll  $s3, $s3, 2                            # Multiply X by 4 (word size)
    sll  $s4, $s4, 7                            # Multiply Y by 128 (shift by 7 bits)
    add  $s3, $s3, $s4                          # Calculate offset (X + Y)

    lw   $t1, ADDR_DSPL
    add  $t1, $t1, $s3                          # Location of the capsule in bitmap
    li   $t5, 0x000000                          # Load the value for black

    # Check for bottom half of capsule.
    beq  $s6, $zero, check_bottom_half          # Check if it's half capsule (no flag)
    bne  $s5, $zero, check_bottom               # Check if capsule is vertical

    # If horizontal, check both sides.
    lw   $t3, 128($t1)                          # Color of left side
    lw   $t4, 132($t1)                          # Color of right side
    bne  $t3, $t5, next_                        # No drop on left
    bne  $t4, $t5, next_                        # No drop on right

    # Update the colors on the bitmap.
    lw   $t3, 0($t1)                            # Load color of left side
    lw   $t4, 4($t1)                            # Load color of right side
    sw   $t5, 0($t1)                            # Set left to black
    sw   $t5, 4($t1)                            # Set right to black
    sw   $t3, 128($t1)                          # Move left color to right side
    sw   $t4, 132($t1)                          # Move right color to right side

    # Update the array to reflect the drop.
    lw   $t6, 4($s0)                            # Load Y coordinate
    addi $t6, $t6, 1                            # Increment Y to move capsule down
    sw   $t6, 4($s0)                            # Store updated Y
    addi $t0, $t0, 1                            # Increment drop counter
    j    next_

check_bottom:
    # Check if under is 0, drop both and update the array.
    lw   $t3, 256($t1)                          # Color below vertical capsule
    bne  $t3, $t5, next_                        # No drop if not black

    # Update the colors on the bitmap
    lw   $t3, 0($t1)                            # Load color at top
    lw   $t4, 128($t1)                          # Load color at bottom
    sw   $t5, 0($t1)                            # Set top to black
    sw   $t3, 128($t1)                          # Move top color down to bottom
    sw   $t4, 256($t1)                          # Set bottom color

    # Update the array to reflect the drop
    lw   $t6, 4($s0)                            # Load Y coordinate
    addi $t6, $t6, 1                            # Increment Y to move capsule down
    sw   $t6, 4($s0)                            # Store updated Y
    addi $t0, $t0, 1                            # Increment drop counter

next_:
    addi $s0, $s0, 16                           # Move to the next element (16 bytes per capsule)
    addi $s1, $s1, 1                            # Increment loop counter
    j    loop_array_                            # Jump back to the loop

check_bottom_half:
    # Check if under is 0, drop and update the array for half capsule.
    lw   $t3, 128($t1)                          # Color below single capsule
    bne  $t3, $t5, next_                        # No drop if not black

    # Update the colors on the bitmap.
    lw   $t3, 0($t1)                            # Load color at top
    sw   $t5, 0($t1)                            # Set top to black
    sw   $t3, 128($t1)                          # Move color down

    # Update the array to reflect the drop.
    lw   $t6, 4($s0)                            # Load Y coordinate
    addi $t6, $t6, 1                            # Increment Y to move capsule down
    sw   $t6, 4($s0)                            # Store updated Y
    addi $t0, $t0, 1                            # Increment drop counter

next_2:
    addi $s0, $s0, 16                           # Move to the next element (16 bytes per capsule)
    addi $s1, $s1, 16                           # Increment loop counter
    j    loop_array_                            # Jump back to the loop

end_loop_:
    beq  $t0, $zero, restore_and_exit           # If no drops, exit

    # Loop again if drops were made.
    la   $s0, capsules                          # Load the base address of the array
    addi $s1, $zero, 0                          # Initialize loop counter
    addi $s2, $zero, 99                         # Length of array
    addi $t0, $zero, 0                          # Reset drop counter
    j    loop_array_
    
restore_and_exit:
    # Restore registers.
    lw   $s0, 0($sp)                            # Restore $s0
    addi $sp, $sp, 4
    lw   $s1, 0($sp)                            # Restore $s1
    addi $sp, $sp, 4
    lw   $s2, 0($sp)                            # Restore $s2
    addi $sp, $sp, 4
    lw   $s3, 0($sp)                            # Restore $s3
    addi $sp, $sp, 4
    lw   $s4, 0($sp)                            # Restore $s4
    addi $sp, $sp, 4
    lw   $s5, 0($sp)                            # Restore $s5
    addi $sp, $sp, 4
    lw   $s6, 0($sp)                            # Restore $s6
    addi $sp, $sp, 4
    lw   $s7, 0($sp)                            # Restore $s7
    addi $sp, $sp, 4
    lw   $t0, 0($sp)                            # Restore $t0
    addi $sp, $sp, 4
    lw   $t1, 0($sp)                            # Restore $t1
    addi $sp, $sp, 4
    lw   $t2, 0($sp)                            # Restore $t2
    addi $sp, $sp, 4
    lw   $t3, 0($sp)                            # Restore $t3
    addi $sp, $sp, 4
    lw   $t4, 0($sp)                            # Restore $t4
    addi $sp, $sp, 4
    lw   $t5, 0($sp)                            # Restore $t5
    addi $sp, $sp, 4
    lw   $t6, 0($sp)                            # Restore $t6
    addi $sp, $sp, 4
    
    jr   $ra                

