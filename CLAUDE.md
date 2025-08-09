# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This is a **GameMaker Studio 2** project converted from a .yyp file, containing a turn-based game implementation. The project follows GameMaker's standard directory structure:

- **`Turnproject.yyp/`** - Main project directory containing all game assets
- **`objects/`** - Game objects with GML (GameMaker Language) scripts
- **`sprites/`** - Character animations and visual assets
- **`scripts/`** - Reusable GML functions
- **`rooms/`** - Game scenes/levels
- **`fonts/`** - Text rendering assets
- **`options/`** - Platform-specific build configurations

## Core Architecture

### Turn-Based Combat System
The game implements a turn-based system with the following key components:

- **`obj_TurnManager`** - Central turn coordinator that maintains a shuffled turn order list of all `obj_Statable` instances
- **`obj_Statable`** - Base class for all turn-participating entities (players and enemies inherit from this)
- **`obj_Player`** - Player character with movement, attack animations, and stats (2 moves per turn, 4 HP, 2 damage)
- **`obj_Enemy`** - Enemy entities with basic stats (0 moves, 4 HP, 0 damage)

### State Management
- **TURNSTATE enum** - Tracks active/inactive turn states
- **Direction/Animation system** - Players have directional sprites (up/down/left/right) with idle/run/attack states
- **Movement system** - Grid-based movement with animation timing

### Key Files
- **`scr_enums.gml`** - Defines TURNSTATE enumeration
- **`move.gml`** - Movement function handling directional movement with speed and animation
- **`damage_text_to_value.gml`** - Utility for damage calculation/display

## Development Notes

### GameMaker Studio 2 Specifics
- This is a **converted project** from .yyp format
- Uses GML (GameMaker Language) syntax
- Follows GameMaker's object-oriented event system (Create, Step, Draw, Alarm events)
- Sprite animations use GameMaker's frame-based system

### No Build Commands
GameMaker Studio 2 projects are typically built through the IDE interface rather than command-line tools. There are no package.json, Makefile, or similar build configuration files.

### File Extensions
- **`.gml`** - GameMaker Language script files
- **`.yy`** - GameMaker resource definition files (JSON format)
- **`.png`** - Sprite assets and animation frames

## Code Conventions
- Variables use snake_case (e.g., `turn_list`, `max_moves`)
- Objects prefixed with `obj_` (e.g., `obj_Player`, `obj_TurnManager`)
- Scripts prefixed with `scr_` for organized scripts (e.g., `scr_enums`)
- Sprites prefixed with descriptive names (e.g., `ch1_down_att` for character 1 down attack)
- Enums use UPPERCASE naming (e.g., `TURNSTATE.active`)