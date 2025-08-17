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

### Character Sprite System
- **Multiple character sprites** - Support for chr1 through chr7 sprite sets with full animations
- **IDE-assignable character_index** - Set character appearance (1-7) directly in GameMaker IDE object properties
- **Automatic fallback** - Missing sprites fall back to chr1, then to dummy sprite if needed
- **Full animation support** - Each character has idle, run_sword, and attack_sword animations for all 4 directions

### UI Management
- **`obj_UIManager`** - Centralized UI state handling for player details and level-up overlays
- **`obj_PlayerDetails`** - Character sheet display with full ability score information
- **`obj_LevelUpOverlay`** - Ability Score Improvement interface for level-up management
- **`obj_CombatLog`** - Advanced collapsible combat log with scrolling and 3-state display system

### Key Script Systems
- **`xp_system.gml`** - Complete leveling system with ASI management and party XP distribution
- **`weapon_system.gml`** - Weapon definitions, special attacks, and combat calculations
- **`character_sprites.gml`** - Character sprite lookup system supporting chr1-chr7 sprite sets
- **`scr_enums.gml`** - Core enumerations including TURNSTATE
- **`move.gml`** - Movement function handling directional movement with speed and animation
- **`damage_text_to_value.gml`** - Utility for damage calculation and display

## Development Commands

### GameMaker Studio 2 IDE
- **Open Project**: Open `Turnproject.yyp/Turnproject.yyp` with GameMaker Studio 2 (2024.13+)
- **Run/Test**: Press F5 to launch Room1 (main game room)
- **Debug**: Press F6 and set breakpoints in object events/scripts  
- **Build**: IDE → Build → Create Executable

### In-Game Testing Controls
- **Player Details**: Press 'I' to toggle character sheet with ability scores and combat stats
- **Level Up Interface**: Press 'I' when ASI (Ability Score Improvement) is available
- **Weapon Switching**: Use number keys 1-9 to switch between available weapons
- **Movement**: Arrow keys to move player character
- **Attack**: Space bar to attack enemies in range
- **Combat Log Controls**:
  - **'L' Key**: Cycle through log states (Full → One-line → Nub → Full)
  - **Mouse Wheel**: Scroll through message history (when hovering over log in full state)
  - **Arrow Keys**: Alternative scrolling (Up/Down keys work regardless of mouse position)
  - **Click Interactions**: Click collapse button to toggle states, click nub to expand

### Testing Documentation
- **Manual Testing**: Use `test_level_system.md` for comprehensive D&D mechanics testing
- **Level Up Testing**: XP values adjusted for faster testing (enemies give 40-85 XP)
- **ASI Testing**: Reach level 4, 8, 12, 16, or 20 to trigger Ability Score Improvement
- **Debug Tools**: Combat log displays all actions and calculations in real-time

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
- **Combat Log System** provides advanced feedback with collapsible interface:
  - **3-State Display**: Full (8 messages + scroll), One-line (latest message), Nub (compact button)
  - **Scrollable History**: Stores up to 50 messages with mouse wheel and arrow key navigation
  - **Color-coded Messages**: Green (hits), red (misses), yellow (damage), orange (criticals)
  - **Smart Auto-scroll**: Automatically follows newest messages when at bottom
  - **Interactive Controls**: L key cycling, collapse button, clickable nub expansion

## Development Notes

### GameMaker Studio 2 Specifics
- This is a **converted project** from .yyp format (requires GameMaker Studio 2024.13+)
- Uses GML (GameMaker Language) syntax with event-driven object system
- Sprite animations use frame-based system with directional naming conventions (`ch1_down_att`, `ch1_left_idle`)
- Global variables manage shared systems (weapons array, combat log function)
- Room1 contains all game instances - TurnManager, Player, Enemies, and UI objects

### Critical System Dependencies
- **`obj_TurnManager`** must exist in Room1 for turn-based combat to function
- **UI System Failsafe**: TurnManager Alarm[1] creates missing UI objects (PlayerDetails, UIManager, LevelUpOverlay)
- **Global Systems**: `init_weapons()` and XP system functions must be called during initialization
- **Combat Log**: Global function `global.combat_log()` provides debugging and player feedback

### Object Instance Management
- **Layer System**: Objects created on "Instances" layer with fallback to depth-based creation
- **Singleton UI**: UI objects (PlayerDetails, UIManager, LevelUpOverlay) should have single instances
- **Character Inheritance**: All combat entities inherit from `character_base` for turn system integration

### File Structure Patterns
- **`.gml`** - GameMaker Language script files containing functions and events
- **`.yy`** - GameMaker resource definition files (JSON format, auto-generated, do not edit manually)
- **`.png`** - Sprite assets organized by character and animation state

## Code Conventions
- **Variables**: snake_case (e.g., `turn_list`, `max_moves`, `xp_to_next_level`)
- **Objects**: `obj_` prefix (e.g., `obj_Player`, `obj_TurnManager`, `obj_UIManager`)
- **Scripts**: `scr_` prefix for organized scripts (e.g., `scr_enums`)
- **Sprites**: descriptive naming with state (e.g., `ch1_down_att`, `ch1_left_idle`)
- **Enums**: UPPERCASE naming (e.g., `TURNSTATE.active`, `TURNSTATE.inactive`)
- **Functions**: verb_noun pattern where appropriate (e.g., `gain_xp`, `update_combat_stats`)

## Common Development Patterns

### Adding New Weapons
1. Add weapon definition to `weapon_system.gml` in `init_weapons()` function
2. Increment the array index and add `create_weapon()` call with special_type
3. Implement special attack logic in combat resolution functions
4. Test with weapon switching keys (1-9) in-game

### Using Character Sprite System
1. **In IDE**: Select obj_Player or obj_Enemy instance, set character_index property (1-7) in object properties
2. **In Code**: Set `character_index = X` before calling `init_character_sprite_matrix(character_index)`
3. **Sprite Requirements**: Ensure sprites follow naming pattern `chr[index]_[action]_[direction]` (e.g., `chr3_idle_down`)
4. **Fallback System**: Missing sprites automatically fall back to chr1 equivalents

### Debugging Combat Issues
- Check `global.combat_log()` output in real-time during gameplay
- Verify `character_base` inheritance for new combat entities
- Ensure `update_combat_stats()` called after ability score changes
- Use GameMaker debugger to inspect `turn_list` contents

### UI System Issues
- If UI objects missing: TurnManager Alarm[1] creates them automatically
- UI overlays controlled by `obj_UIManager` singleton
- Player details accessible via 'I' key (handled in UIManager Step event)
- ASI overlay triggers automatically on level-up at ASI levels (4,8,12,16,20)

### Performance Considerations
- Turn system uses `ds_list` for turn_list management - always clean up with `ds_list_destroy()`
- Combat log stored as global function to minimize memory allocation
- Sprite animations cached by GameMaker - avoid frequent sprite swapping
- Use `alarm` events instead of Step events for delayed actions when possible