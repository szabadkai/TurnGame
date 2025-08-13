# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This is a **GameMaker Studio 2** project converted from a .yyp file, containing a turn-based RPG with D&D-inspired mechanics. The project follows GameMaker's standard directory structure:

- **`Turnproject.yyp/`** - Main project directory containing all game assets
- **`objects/`** - Game objects with GML (GameMaker Language) scripts
- **`sprites/`** - Character animations and visual assets
- **`scripts/`** - Reusable GML functions and systems
- **`rooms/`** - Game scenes/levels
- **`fonts/`** - Text rendering assets
- **`options/`** - Platform-specific build configurations

## Core Architecture

### Turn-Based Combat System
The game implements a sophisticated turn-based system with the following key components:

- **`obj_TurnManager`** - Central turn coordinator that maintains a shuffled turn order list of all `character_base` instances
- **`character_base`** - Base class for all turn-participating entities with shared combat properties
- **`obj_Player`** - Player character with D&D-style ability scores, leveling, and weapon switching
- **`obj_Enemy`** - Enemy entities with basic stats and simple AI

### D&D-Inspired Character System
- **Ability Scores** - Six core abilities (STR, DEX, CON, INT, WIS, CHA) with modifiers following D&D 5e rules
- **Leveling System** - XP-based progression with ability score improvements every 4 levels
- **Proficiency Bonus** - Scales with level following D&D 5e progression (2-6)
- **Combat Stats** - Attack bonus, damage, and AC calculated from ability scores + proficiency + equipment

### Advanced Weapon System
- **14 unique weapons** with special abilities (finesse, chain lightning, area attacks, status effects)
- **Special mechanics** including freeze, burn, reflection, counter-attacks, and self-harm
- **Dynamic stats** - Weapons modify attack/damage based on ability scores and proficiency

### UI Management
- **`obj_UIManager`** - Centralized UI state handling for player details and level-up overlays
- **`obj_PlayerDetails`** - Character sheet display with full ability score information
- **`obj_LevelUpOverlay`** - Ability Score Improvement interface for level-up management
- **`obj_CombatLog`** - Scrolling combat log with detailed turn information

### Key Script Systems
- **`xp_system.gml`** - Complete leveling system with ASI management and party XP distribution
- **`weapon_system.gml`** - Weapon definitions, special attacks, and combat calculations
- **`scr_enums.gml`** - Core enumerations including TURNSTATE
- **`move.gml`** - Movement function handling directional movement with speed and animation
- **`damage_text_to_value.gml`** - Utility for damage calculation and display

## Development Commands

### GameMaker Studio 2 IDE
- **Open Project**: Open `Turnproject.yyp/Turnproject.yyp` with GameMaker Studio 2 (2023+)
- **Run/Test**: Press F5 to launch the default room
- **Debug**: Press F6 and set breakpoints in object events/scripts  
- **Build**: IDE → Build → Create Executable

### Testing
- **Manual Testing**: Use test documentation files like `test_level_system.md`
- **Debug Tools**: Use debugger and on-screen overlays for logs during runs
- **Test Rooms**: Create temporary test rooms as `rm_test_*` with helper `obj_test_*` objects

## Architecture Patterns

### Inheritance Hierarchy
- **`character_base`** provides shared properties for all combat entities
- **Object events** handle specific behaviors (Create, Step, Draw, Alarm)
- **Scripts** contain reusable functions accessible across all objects

### Combat Flow
1. **TurnManager** shuffles all `character_base` instances into turn order
2. **Active character** can move and attack based on their stats and weapon
3. **Special abilities** trigger based on weapon type and dice rolls
4. **Status effects** (freeze, burn) are processed each turn
5. **XP distribution** happens after combat with automatic leveling

### UI State Management
- **UIManager** coordinates all interface overlays
- **Player input** (I key) toggles character details or ASI overlay
- **Combat log** provides detailed feedback for all actions

## Development Notes

### GameMaker Studio 2 Specifics
- This is a **converted project** from .yyp format
- Uses GML (GameMaker Language) syntax with event-driven object system
- Sprite animations use frame-based system with directional naming conventions
- Global variables manage shared systems (weapons, combat log)

### File Structure Patterns
- **`.gml`** - GameMaker Language script files containing functions and events
- **`.yy`** - GameMaker resource definition files (JSON format, auto-generated)
- **`.png`** - Sprite assets organized by character and animation state

## Code Conventions
- **Variables**: snake_case (e.g., `turn_list`, `max_moves`, `xp_to_next_level`)
- **Objects**: `obj_` prefix (e.g., `obj_Player`, `obj_TurnManager`, `obj_UIManager`)
- **Scripts**: `scr_` prefix for organized scripts (e.g., `scr_enums`)
- **Sprites**: descriptive naming with state (e.g., `ch1_down_att`, `ch1_left_idle`)
- **Enums**: UPPERCASE naming (e.g., `TURNSTATE.active`, `TURNSTATE.inactive`)
- **Functions**: verb_noun pattern where appropriate (e.g., `gain_xp`, `update_combat_stats`)