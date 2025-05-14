# Pong Game in Assembly Language

This project is a classic Pong game recreated using **x86 Assembly Language**, developed as part of the **CSE341: Microprocessors and Assembly Language** course. It runs on the **EMU8086 emulator** and demonstrates low-level programming concepts including direct memory access, keyboard input handling, BIOS interrupts, and basic game logic.

## 🎮 Gameplay

- Two-player Pong game with keyboard controls.
- Left paddle: Controlled using `w` (up) and `s` (down).
- Right paddle: Controlled using `o` (up) and `l` (down).
- The ball bounces off paddles and screen edges.
- **If a player misses the ball, the opponent scores 1 point.**
- **First player to reach 3 points wins the game.**
- The game resets after each point, and ends when a player wins.

## 🛠️ Technologies Used

- Assembly Language (x86, 16-bit real mode)
- EMU8086 Emulator
- BIOS Interrupts (`INT 10h` for graphics, `INT 16h` for input)

## 🧠 Features

- Real-time paddle and ball movement
- Collision detection with paddles and walls
- Scoring system with display
- Win condition: 3 points
- Text-based graphics in video mode 3
- Manual screen redraw and game reset logic


## 🚀 Getting Started

To run the game:

1. Download and install EMU8086
2. Clone the repository:
   ```bash
   git clone https://github.com/Erfan-Khan-Dhrubo/Pong-Game.git
   ```
3. Open `Pong Game.asm` in EMU8086.
4. Compile and run the program.

> ⚠️ The game is built for real-mode 16-bit emulation and works best on EMU8086 or DOSBox.

## 📚 Learning Objectives

- Gain hands-on experience with low-level hardware programming
- Implement real-time logic using interrupts and polling
- Learn how early games were developed without libraries or graphics engines

  
## 📸 Screenshots 

<img src="./game visualization/pic1.png">
<img src="./game visualization/pic2.png">
<img src="./game visualization/pic3.png">

## LICENSE

This project is licensed under the terms of the [MIT License](LICENSE). 

