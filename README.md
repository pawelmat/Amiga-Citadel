# Amiga Citadel 1.0 (original version)

## Introduction

This is the original version of the 1995 Amiga game "Citadel" by Virtual Design.

It contains the original code and data, although some of it is missing - for example the intro animations are not there any more. It also contains the editor which has been slightly updated in later years for the purpose of 1.3 Citadel "Remonstered". Note: this repo does not include the "Remonstered" version.

## System Requirements

Minimum configuration: Any Amiga with a minimum of 0.5MB Chip + 0.5MB other (prefferably Fast) memory. Additional memory is required for WHDLoad to run.

Suggested configuration: Amiga 1200 with 68020/14MHz or faster with minimum 0.5MB Chip and 1MB+ Fast memory. 

## Development environment

After cloning the repo into e.g. DH0:/Citadel, add the following to your startup-sequence:

- assign >NIL: DATA: SYSTEM:Citadel/DATA/game
- assign >NIL: CODE: SYSTEM:Citadel/CODE
- assign >NIL: EDITOR: SYSTEM:Citadel/Editor


A system with minimum 1MB chip and 4 MB Fast memory is required. Can be a real Amiga or emulator-based.

The game can be assembled using AsmOne (v1.20 or newer). On starting it allocate a minimum of 500kb of Public or Fast memory for your workspace. The main file is in CODE/MAIN1/CytadelaHD_134.ss and the entry point is labeled 's'. 

### Running the game from AsmOne

In order to run the main game engine from assembler:
1. Navigate to the directory where you cloned this project and go to CODE/MAIN1/
2. Load AsmOne (v1.20 or newer).
3. Select 'p' and then '500' to allocate working memory.
4. Load the main Citadel source code file 'CytadelaHD_134.ss' into the AsmOne editor (r CytadelaHD_134.ss)
5. Press ESC to go into the actual assembler editor. Towards the top of the file find the BASE labels pointing to CHIP and FAST memoryto used, change them to where you have a free 0.5MB CHIP and 0.5MB FAST memory. This can be checked using SysInfo or a similar tool.
6. Press ESC again to go to the AsmOne command window.
7. Assemble (a), load externs (e) and run the game (j s).

A similar procedure should be followego to assemble and run other parts of the game (such as the menu or the intro) although some data files might be not in the right locations or just missing - this needs sorting out.

## Copyright and License
Copyright (C) 1995, 2022 Pawel Matusz, Artur Bardowski, Artur Opala.

This software is free to copy and use for non-commercial purposes under the terms of the GNU GPL-3.0 license. 

## Warranty
This package comes with absolutely no warranty of any kind, either express or implied, statutory or otherwise. The entire risk as to use, results and performance of the package is assumed by you and if the package should prove to be defective, you assume the entire cost of all necessary servicing, repair or other remediation. Under no circumstances, can the authors be held responsible for any damage caused in any usual, special, or accidental way, also if the owner or a third party has been pointed at such possibilities of damage.
