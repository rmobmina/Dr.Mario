# Dr. Mario Assembly Project

## Project Overview
This project implements a simplified version of the classic arcade game **Dr. Mario** using MIPS assembly language. The game involves aligning falling capsules to eliminate viruses, combining logic, strategy, and speed. It was developed and tested using the MARS and Saturn IDEs, featuring a bitmap display and keyboard input simulation.

This project was completed as part of **CSC258H1: Computer Organization** at the University of Toronto.

## Features Implemented

### Milestone 1: Static Scene Rendering
- **Medicine Bottle**: The playing field is rendered as a vertical grid resembling a medicine bottle.
- **Initial Capsule**: A two-halved capsule with random colors (red, yellow, or blue) is generated at the default starting position.

### Milestone 2: Basic Controls and Gameplay
- **Keyboard Controls**: 
  - `W` rotates the capsule clockwise.
  - `A` moves the capsule left.
  - `D` moves the capsule right.
  - `S` drops the capsule quickly.
  - `Q` quits the game.
- **Frame Update**: The game screen updates at 60 frames per second to ensure smooth gameplay.

### Milestone 3: Collision Detection
- **Wall Collision**: Capsules stop moving horizontally when hitting the playing field boundaries.
- **Stack Collision**: Capsules stop falling when landing on other capsules, viruses, or the bottom of the field.
- **Clearing Rows**: Four or more aligned blocks of the same color are removed, and unsupported blocks fall. This process repeats if additional alignments occur.
- **Game Over**: The game ends when a new capsule cannot be placed at the top of the field.

### Milestones 4 & 5: Additional Gameplay Features
- **Gravity**: Capsules automatically descend one row every second.
- **Increasing Speed**: Gravity speed increases over time or after clearing a certain number of rows.
- **Game Over Screen**: Displays a "Game Over" message in pixels and allows for restarting.
- **Sound Effects**: 
  - Capsule rotation, drop, and row clearing.
  - Game over notification.
- **Pause Feature**: Pause the game with `P` and resume with `P` again.
- **Preview Panel**: Shows the next 4-5 capsules dynamically, helping players strategize.
- **Themed Graphics**: Dr. Mario and virus sprites on side panels emulate the original game's aesthetics.
- **Background Music**: Plays the Dr. Mario theme music for a nostalgic experience.

## How to Play
1. Open `DrMario.asm` in either MARS or Saturn IDE.
2. Configure the bitmap display:
   - **Base Address**: `0x10008000`
   - **Display Width**: `256 pixels`
   - **Display Height**: `256 pixels`
   - **Unit Size**: `2x2 pixels`
3. Ensure the keyboard input is connected and focused.
4. Run the program and use the following controls:
   - `W`: Rotate the capsule clockwise.
   - `A`: Move the capsule left.
   - `D`: Move the capsule right.
   - `S`: Drop the capsule quickly.
   - `P`: Pause/Resume the game.
   - `Q`: Quit the game.
5. Aim to eliminate viruses by aligning rows or columns of four matching blocks.

## License and Copyright

This project is developed as part of an academic assignment and is not intended for commercial use. 

**Copyright (c) 2024 Reena Obmina & Nena Harsch**  

All rights reserved. Redistribution or use of the code, in whole or in part, without explicit permission from the authors is prohibited. This project is a tribute to the classic game **Dr. Mario** and is not affiliated with or endorsed by Nintendo.

---
